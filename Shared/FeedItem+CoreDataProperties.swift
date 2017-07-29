//
//  FeedItem+CoreDataProperties.swift
//  
//
//  Created by Porter Hoskins on 7/29/17.
//
//

import Foundation
import CoreData


extension FeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItem> {
        return NSFetchRequest<FeedItem>(entityName: "FeedItem")
    }

    @NSManaged public var identifier: String
    @NSManaged public var itemDescription: String
    @NSManaged public var index: Int64
    @NSManaged public var title: String

}
