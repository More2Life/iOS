//
//  FeedItem+CoreDataClass.swift
//  
//
//  Created by Porter Hoskins on 7/29/17.
//
//

import Foundation
import CoreData
import Services
import Alamofire

public let localizedDonateString = NSLocalizedString("Donate", comment: "Video type string")

let feedItemQueue = DispatchQueue(label: "com.coachkalani.more2life.feeditem")

public enum FeedItemType: String {
    case story = "story"
    case event = "event"
    case listing = "listing"
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .story:
            return NSLocalizedString("Video", comment: "Video type string")
        case .event:
            return NSLocalizedString("Event", comment: "Event type string")
        case .listing:
            return NSLocalizedString("Shop", comment: "Listing type string")
        case .unknown:
            return ""
        }
    }
    
    public var localizedCallToActionTitle: String {
        switch self {
        case .story:
            return localizedDonateString
        case .event:
            return NSLocalizedString("Register", comment: "Event type string")
        case .listing:
            return NSLocalizedString("Buy", comment: "Listing type string")
        case .unknown:
            return ""
        }
    }
    
    public var localizedConfirmationTitle: String {
        switch self {
        case .story:
            return localizedDonateString
        case .event:
            return NSLocalizedString("Register", comment: "Event type string")
        case .listing:
            return NSLocalizedString("Checkout", comment: "Listing type string")
        case .unknown:
            return ""
        }
    }
}

public class FeedItem: NSManagedObject {
    
    @NSManaged fileprivate var primitiveType: String
    static let typeKey = "type"
    
    public var type: FeedItemType {
        get {
            willAccessValue(forKey: FeedItem.typeKey)
            let type = FeedItemType(rawValue: primitiveType)
            assert(type != nil, "type should never be nil on a feed item! primitiveType -> \(primitiveType)")
            didAccessValue(forKey: FeedItem.typeKey)
            
            return type ?? .unknown
        } set {
            willChangeValue(forKey: FeedItem.typeKey)
            primitiveType = newValue.rawValue
            didChangeValue(forKey: FeedItem.typeKey)
        }
    }
    
    /// Imports feed items from the server
    ///
    /// - Parameters:
    ///   - context: the core data context from which to insert/fetch the feed item
    ///   - completion: called when the import has finished and the feed items have been put into core data
    public static func `import`(in context: NSManagedObjectContext, completion: @escaping (_ error: Error?)->()) {
        FeedItemService.import() { json in
            feedItemQueue.async {
                context.performAndWait {
                    defer {
                        completion(nil)
                    }
                    
                    guard let json = json else { return }
                    
                    // Parse new items
                    var items: [FeedItem] = []
                    for item in json {
                        guard let feedItem = feedItem(from: item, in: context) else { continue }
                        items.append(feedItem)
                    }
                    
                    // Cleanup old feed items
                    do {
                        let fetchRequest: NSFetchRequest<FeedItem> = FeedItem.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "NOT (SELF IN %@)", items)
                        
                        let result = try context.fetch(fetchRequest)
                        result.forEach { context.delete($0) }
                    } catch {
                        print("Couldn't clean up FeedItems \(error)")
                    }
                    
                    context.persist()
                }
            }
        }
    }
    
    
    /// Parses and returns a feed item given JSON
    ///
    /// - Parameters:
    ///   - json: The json for a feed item
    ///   - context: the core data context from which to fetch the feed item
    /// - Returns: a feed item for the json
    @discardableResult
    static func feedItem(from json: [String : Any], in context: NSManagedObjectContext) -> FeedItem? {
        guard let identifier = json["_id"] as? String,
            let title = json["title"] as? String,
            let description = json["description"] as? String,
            let type = FeedItemType(rawValue: (json["type"] as? String ?? "").lowercased()) else { return nil }
        
        var feedItem = FeedItem.fetch(withID: identifier, in: context)
        if feedItem == nil {
            switch type {
            case .story:
                feedItem = StoryFeedItem(context: context)
            case .event:
                feedItem = EventFeedItem(context: context)
            case .listing:
                feedItem = ListingFeedItem(context: context)
            default: break
            }
        }
        
        feedItem?.identifier = identifier
        feedItem?.type = type
        feedItem?.title = title
        feedItem?.itemDescription = description
		feedItem?.createdAt = ISO8601DateFormatter().date(from:(json["createdAt"] as? String ?? ""))
        feedItem?.isActive = json["isActive"] as? Bool ?? false
        feedItem?.previewImageURL = json["feedImageUrl"] as? String ?? json["imageUrl"] as? String
        
        switch type {
        case .story:
            StoryFeedItem.hydrate(feedItem, with: json)
        case .event:
            EventFeedItem.hydrate(feedItem, with: json)
        case .listing:
            ListingFeedItem.hydrate(feedItem, with: json, in: context)
        default: break
        }
        
        return feedItem
    }
    
    
    /// Fetches a single feed item from the database given a identifier
    ///
    /// - Parameters:
    ///   - identifier: the unique identifier of the feed item
    ///   - context: the core data context from which to fetch the feed item
    /// - Returns: a feed item if one exists
    static func fetch(withID identifier: String, in context: NSManagedObjectContext) -> FeedItem? {
        let fetchRequest: NSFetchRequest<FeedItem> = FeedItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(FeedItem.identifier), identifier)
        
        do {
            let result = try context.fetch(fetchRequest)
            assert(result.count < 2, "Duplicate feed items in context!")
            
            return result.first
        } catch {
            print("Error finding Feed item \(identifier) \(error)")
            return nil
        }
    }
    
    /// Returns a image for a preview image url string. If the image is cached it will fetch from disk, otherwise
    /// it will go to the network to get it.
    ///
    /// - Parameters:
    ///   - urlString: The url string pointing to an image.
    ///   - completion: returns the image and the request
    /// - Returns: The request made to the server for the image.
    @discardableResult
    public static func previewImage(with urlString: String, for feedItem: FeedItem, in context: NSManagedObjectContext, completion: @escaping (_ image: UIImage?, _ request: URLRequest?) -> ()) -> DataRequest? {
        if let image = imageCache.object(forKey: urlString as NSString) {
            // Get image out of memory
            completion(image, nil)
            return nil
        } else if let imageData = feedItem.previewImage, let image = UIImage(data: imageData as Data) {
            // Get image off of disk
            imageCache.setObject(image, forKey: urlString as NSString)
            completion(image, nil)
            return nil
        } else {
            // Try to get image from the network
            return UIImage.fetch(with: urlString) { image, request in
                guard let image = image, let data = UIImagePNGRepresentation(image) else { return }
                context.perform {
                    feedItem.previewImage = data as NSData
                    context.persist()
                }
            }
        }
    }
}
