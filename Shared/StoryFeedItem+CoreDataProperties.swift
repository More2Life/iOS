//
//  StoryFeedItem+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension StoryFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryFeedItem> {
        return NSFetchRequest<StoryFeedItem>(entityName: "StoryFeedItem")
    }

    @NSManaged public var videoURL: String?
    @NSManaged public var publishDate: NSDate?
    @NSManaged public var views: Int64

}
