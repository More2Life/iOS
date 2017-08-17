//
//  EventFeedItem+CoreDataClass.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

@objc(EventFeedItem)
public class EventFeedItem: FeedItem {

    /// Hydrates the feed item with event specific data
    ///
    /// - Parameters:
    ///   - feedItem: the event feed item
    ///   - json: the json for the individual feed item
    class func hydrate(_ feedItem: FeedItem?, with json: [String : Any]) {
        guard let feedItem = feedItem as? EventFeedItem else { return }
        
        feedItem.eventURL = json["eventUrl"] as? String
        feedItem.address = json["address"] as? String
        feedItem.coordinates = json["coordinates"] as? String
        feedItem.previewImageURL = json["imageUrl"] as? String
    }
}
