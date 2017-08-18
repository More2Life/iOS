//
//  ListingFeedItem+CoreDataClass.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import CoreData

let priceFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter
}()

@objc(ListingFeedItem)
public class ListingFeedItem: FeedItem {
    
    public var formattedPrice: String? {
        guard let price = product?.price else { return nil }
        return priceFormatter.string(from: NSNumber(value: price))
    }

    /// Hydrates the feed item with listing specific data
    ///
    /// - Parameters:
    ///   - feedItem: the listing feed item
    ///   - json: the json for the individual feed item
    class func hydrate(_ feedItem: FeedItem?, with json: [String : Any], in context: NSManagedObjectContext) {
        guard let feedItem = feedItem as? ListingFeedItem else { return }
        
        guard let productJSON = json["Product"] as? [String : Any] else { return }
        feedItem.product = Product.product(from: productJSON, in: context)
    }
}
