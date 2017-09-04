//
//  ListingFeedItem+CoreDataClass.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

@objc(ListingFeedItem)
public class ListingFeedItem: FeedItem {

    /// Hydrates the feed item with listing specific data
    ///
    /// - Parameters:
    ///   - feedItem: the listing feed item
    ///   - json: the json for the individual feed item
    class func hydrate(_ feedItem: FeedItem?, with json: [String : Any], in context: NSManagedObjectContext) {
        guard let feedItem = feedItem as? ListingFeedItem else { return }
        feedItem.previewImageURL = json["feedImageUrl"] as? String
        feedItem.productID = json["productId"] as? String ?? ""
    }
}
