//
//  VideoFeedItem+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension VideoFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoFeedItem> {
        return NSFetchRequest<VideoFeedItem>(entityName: "VideoFeedItem")
    }

    @NSManaged public var previewImageURL: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var publishDate: NSDate?
    @NSManaged public var views: Int64

}
