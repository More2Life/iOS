//
//  ProductVariant+CoreDataClass.swift
//  
//
//  Created by Porter Hoskins on 9/2/17.
//
//

import Foundation
import CoreData

@objc(ProductVariant)
public class ProductVariant: NSManagedObject {

    /// Parses and returns a product given JSON
    ///
    /// - Parameters:
    ///   - json: The json for a product
    ///   - context: the core data context from which to fetch the product
    /// - Returns: a product for the json
    @discardableResult
    static func variant(from json: [String : Any], in context: NSManagedObjectContext) -> ProductVariant? {
        guard let identifier = json["_id"] as? String else { return nil }
        
        var variant = ProductVariant.fetch(withID: identifier, in: context)
        if variant == nil {
            variant = ProductVariant(context: context)
        }
        
        variant?.identifier = identifier
        variant?.title = json["title"] as? String ?? ""
        variant?.inventoryQuantity = json["inventoryQuantity"] as? NSNumber ?? 0
        variant?.vendorID = (json["vendorId"] as? NSNumber)?.stringValue ?? ""
        
        return variant
    }

    /// Fetches a single product variant from the database given a identifier
    ///
    /// - Parameters:
    ///   - identifier: the unique identifier of the feed item
    ///   - context: the core data context from which to fetch the feed item
    /// - Returns: a feed item if one exists
    static func fetch(withID identifier: String, in context: NSManagedObjectContext) -> ProductVariant? {
        let fetchRequest: NSFetchRequest<ProductVariant> = ProductVariant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Product.identifier), identifier)
        
        do {
            let result = try context.fetch(fetchRequest)
            assert(result.count < 2, "Duplicate products in context!")
            
            return result.first
        } catch {
            print("Error finding product \(identifier) \(error)")
            return nil
        }
    }
}
