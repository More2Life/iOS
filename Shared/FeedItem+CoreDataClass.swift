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

let feedItemQueue = DispatchQueue(label: "com.coachkalani.more2life.feeditem")

public enum FeedItemType: String {
    case video = "video"
    case event = "event"
    case listing = "listing"
    case unknown
    
    public var localizedDescription: String {
        switch self {
        case .video:
            return NSLocalizedString("Video", comment: "Video type string")
        case .event:
            return NSLocalizedString("Event", comment: "Event type string")
        case .listing:
            return NSLocalizedString("Shop", comment: "Listing type string")
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
                    
                    for item in json {
                        feedItem(from: item, in: context)
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
            let index = json["index"] as? Int64,
            let description = json["description"] as? String,
            let type = FeedItemType(rawValue: (json["type"] as? String ?? "").lowercased()) else { return nil }
        
        var feedItem = FeedItem.fetch(withID: identifier, in: context)
        if feedItem == nil {
            switch type {
            case .video:
                feedItem = VideoFeedItem(context: context)
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
        feedItem?.index = index
        feedItem?.itemDescription = description
        feedItem?.isActive = json["isActive"] as? Bool ?? false
        
        switch type {
        case .video:
            VideoFeedItem.hydrate(feedItem, with: json)
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
}
