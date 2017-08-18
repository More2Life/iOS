//
//  StoryFeedItem+CoreDataClass.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

@objc(StoryFeedItem)
public class StoryFeedItem: FeedItem {

    /// Hydrates the feed item with video specific data
    ///
    /// - Parameters:
    ///   - feedItem: the video feed item
    ///   - json: the json for the individual feed item
    class func hydrate(_ feedItem: FeedItem?, with json: [String : Any]) {
        guard let feedItem = feedItem as? StoryFeedItem else { return }
        
        feedItem.previewImageURL = json["previewImageUrl"] as? String
        feedItem.videoURL = json["videoUrl"] as? String
        feedItem.views = json["views"] as? Int64 ?? 0
    }
}
