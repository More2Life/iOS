//
//  DonationFeedItem+CoreDataClass.swift
//  
//
//  Created by Brendan Kingsford on 10/24/17.
//
//

import Foundation
import CoreData

@objc(DonationFeedItem)
public class DonationFeedItem: FeedItem {
	
	/// Hydrates the feed item with listing specific data
	///
	/// - Parameters:
	///   - feedItem: the donation feed item
	///   - json: the json for the individual feed item
	class func hydrate(_ feedItem: FeedItem?, with json: [String : Any], in context: NSManagedObjectContext) {
		guard let feedItem = feedItem as? DonationFeedItem else { return }
		feedItem.previewImageURL = json["feedImageUrl"] as? String
		feedItem.donationID = json["handle"] as? String ?? ""
	}
}
