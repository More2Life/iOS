//
//  ListingItemExtension.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/4/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import Shared
import Storefront

let priceFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter
}()

extension ListingFeedItem {
//        public var formattedPrice: String? {
//            guard let price = product?.price else { return nil }
//            return priceFormatter.string(from: NSNumber(value: price))
//        }
    
    var price: String? {
        return Client.shared.products[productID]?.price
    }
}
