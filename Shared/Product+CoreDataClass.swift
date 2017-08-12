//
//  Product+CoreDataClass.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

@objc(Product)
public class Product: NSManagedObject {

    /// Parses and returns a product given JSON
    ///
    /// - Parameters:
    ///   - json: The json for a product
    ///   - context: the core data context from which to fetch the product
    /// - Returns: a product for the json
    @discardableResult
    static func product(from json: [String : Any], in context: NSManagedObjectContext) -> Product? {
        guard let identifier = json["_id"] as? String, let price = json["price"] as? Double else { return nil }
        
        var product = Product.fetch(withID: identifier, in: context)
        if product == nil {
            product = Product(context: context)
        }
        
        product?.identifier = identifier
        product?.price = price
        
        return product
    }
    
    /// Fetches a single product from the database given a identifier
    ///
    /// - Parameters:
    ///   - identifier: the unique identifier of the feed item
    ///   - context: the core data context from which to fetch the feed item
    /// - Returns: a feed item if one exists
    static func fetch(withID identifier: String, in context: NSManagedObjectContext) -> Product? {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
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
