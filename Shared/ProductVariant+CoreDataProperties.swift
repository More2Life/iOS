//
//  ProductVariant+CoreDataProperties.swift
//  
//
//  Created by Porter Hoskins on 9/2/17.
//
//

import Foundation
import CoreData


extension ProductVariant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductVariant> {
        return NSFetchRequest<ProductVariant>(entityName: "ProductVariant")
    }

    @NSManaged public var title: String
    @NSManaged public var inventoryQuantity: NSNumber
    @NSManaged public var vendorID: String
    @NSManaged public var identifier: String
    @NSManaged public var product: Product

}
