//
//  Product+CoreDataProperties.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var identifier: String
    @NSManaged public var price: Double
    @NSManaged public var feedItem: ListingFeedItem?
    @NSManaged public var variants: NSOrderedSet

}

// MARK: Generated accessors for variants
extension Product {

    @objc(insertObject:inVariantsAtIndex:)
    @NSManaged public func insertIntoVariants(_ value: ProductVariant, at idx: Int)

    @objc(removeObjectFromVariantsAtIndex:)
    @NSManaged public func removeFromVariants(at idx: Int)

    @objc(insertVariants:atIndexes:)
    @NSManaged public func insertIntoVariants(_ values: [ProductVariant], at indexes: NSIndexSet)

    @objc(removeVariantsAtIndexes:)
    @NSManaged public func removeFromVariants(at indexes: NSIndexSet)

    @objc(replaceObjectInVariantsAtIndex:withObject:)
    @NSManaged public func replaceVariants(at idx: Int, with value: ProductVariant)

    @objc(replaceVariantsAtIndexes:withVariants:)
    @NSManaged public func replaceVariants(at indexes: NSIndexSet, with values: [ProductVariant])

    @objc(addVariantsObject:)
    @NSManaged public func addToVariants(_ value: ProductVariant)

    @objc(removeVariantsObject:)
    @NSManaged public func removeFromVariants(_ value: ProductVariant)

    @objc(addVariants:)
    @NSManaged public func addToVariants(_ values: NSOrderedSet)

    @objc(removeVariants:)
    @NSManaged public func removeFromVariants(_ values: NSOrderedSet)

}
