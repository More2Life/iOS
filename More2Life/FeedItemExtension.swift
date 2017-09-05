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
    
    var product: ProductViewModel? {
        return Client.shared.products[productID]
    }
    
    var price: String? {
        return product?.price
    }

}


extension FeedItem {
    var buttonOverlayColor: UIColor {
        switch self {
        case let listingFeedItem as ListingFeedItem:
            return listingFeedItem.product?.tags.contains("light-background") == true ? .lightGray : .white
        default:
            return .white
        }
        
    }
}
