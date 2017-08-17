//
//  EventFeedItem+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension EventFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventFeedItem> {
        return NSFetchRequest<EventFeedItem>(entityName: "EventFeedItem")
    }

    @NSManaged public var eventURL: String?
    @NSManaged public var address: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var previewImageURL: String?
}
