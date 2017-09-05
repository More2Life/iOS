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

extension ListingFeedItem {
    
    var price: String? {
        return Client.shared.products[productID]?.price
    }
}
