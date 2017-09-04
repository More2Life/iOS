//
//  ListingFeedItem+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension ListingFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListingFeedItem> {
        return NSFetchRequest<ListingFeedItem>(entityName: "ListingFeedItem")
    }

    @NSManaged public var productID: String

}
