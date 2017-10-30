//
//  DonationFeedItem+CoreDataProperties.swift
//  
//
//  Created by Brendan Kingsford on 10/24/17.
//
//

import Foundation
import CoreData


extension DonationFeedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DonationFeedItem> {
        return NSFetchRequest<DonationFeedItem>(entityName: "DonationFeedItem")
    }

    @NSManaged public var donationID: String

}
