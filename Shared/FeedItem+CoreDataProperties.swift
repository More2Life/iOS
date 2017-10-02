//
//  FeedItem+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/17/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension FeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItem> {
        return NSFetchRequest<FeedItem>(entityName: "FeedItem")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var isActive: Bool
	@NSManaged public var createdAt: Date?
    @NSManaged public var itemDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var previewImageURL: String?
    @NSManaged public var previewImage: NSData?

}
