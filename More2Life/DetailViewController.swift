//
//  DetailViewController.swift
//  More2Life
//
//  Created by Porter Hoskins on 8/12/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Shared
import SafariServices
import PassKit
import AVKit
import AVFoundation
import Pay
import Fabric
import Crashlytics

class DetailViewController: UIViewController, FeedDetailing {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var playButton: UIButton?
	@IBOutlet weak var priceButton: PriceButton!
	
    @IBOutlet weak var actionStackView: UIStackView?
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var actionGradientView: UIView?
    
    var feedItem: FeedItem?
    
    var paySession: PaySession?
	
	var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Answers KPI
		Answers.logContentView(withName: feedItem?.title,
									   contentType: "Feed Item Detail",
									   contentId: feedItem?.identifier,
									   customAttributes: [:])

        title = feedItem?.title
        if let data = (feedItem?.itemDescription ?? "").data(using: .utf8) {
            do {
                let attributedString = try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                
                descriptionLabel?.text = attributedString.string
            } catch {
                descriptionLabel?.text = feedItem?.itemDescription
            }
        } else {
            descriptionLabel?.text = feedItem?.itemDescription
        }
        actionButton?.setTitle(feedItem?.type.localizedCallToActionTitle, for: .normal)
        playButton?.isHidden = true
		priceButton?.isHidden = true
        
        guard let feedItem = feedItem else { return }
        
        switch feedItem {
        case _ as EventFeedItem:
            break
		case let feedItem as StoryFeedItem:
            if feedItem.videoURL != nil {
                playButton?.isHidden = false
            }
		case let feedItem as ListingFeedItem:
			priceButton?.isHidden = false
			let price = feedItem.price
			priceButton?.setTitle(price, for: .normal)
			priceButton?.borderColor = feedItem.buttonOverlayColor
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = scrollView?.contentInset.top ?? 0
        let bottom = (actionStackView?.frame.height ?? 0) + 32 + (tabBarController?.tabBar.frame.height ?? 0)
        scrollView?.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        guard let feedItem = feedItem else { return }
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let buyModalViewController: BuyModalViewController = storyboard.instantiateViewController()
		self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: buyModalViewController)
		
		buyModalViewController.modalPresentationStyle = .custom
		buyModalViewController.transitioningDelegate = self.halfModalTransitioningDelegate
		
        switch feedItem {
        case let feedItem as EventFeedItem:
            guard let eventURLString = feedItem.eventURL, let url = URL(string: eventURLString) else { break }
			
			// Answers KPI
			Answers.logCustomEvent(withName: "Register Button Tapped",
								   customAttributes: [
									"fromView": "Feed Item Detail",
									"forItem": eventURLString])
            
            present(SFSafariViewController(url: url), animated: true, completion: nil)
			
		case let feedItem as ListingFeedItem:
			buyModalViewController.mode = .action(feedItem: feedItem)
			// Answers KPI
			Answers.logCustomEvent(withName: "Buy Button Tapped",
								   customAttributes: [
									"fromView": "Feed Item Detail",
									"forItem": feedItem.productID])
		case let feedItem as DonationFeedItem:
			buyModalViewController.mode = .action(feedItem: feedItem)
			// Answers KPI
			Answers.logCustomEvent(withName: "Donate Button Tapped",
								   customAttributes: [
									"fromView": "Feed Item Detail",
									"forItem": feedItem.donationID])
        default:
			buyModalViewController.mode = .donate
			// Answers KPI
			Answers.logCustomEvent(withName: "Action Button Tapped",
								   customAttributes: [
									"fromView": "Feed Item Detail"])
		}
		present(buyModalViewController, animated: true, completion: nil)
    }
    
    @IBAction func playTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "playVideo", sender: feedItem)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender else { return }
        
        switch segue.destination {
        case let viewController as AVPlayerViewController:
            guard let item = sender as? StoryFeedItem, let url = URL(string: item.videoURL ?? "") else { break }
            let player = AVPlayer(url: url)
            player.play()
            viewController.player = player
        case let viewController as ImagePageViewController:
            guard let feedItem = feedItem else { return }
            
            switch feedItem {
            case let feedItem as ListingFeedItem:
                guard let product = feedItem.product else { break }
                viewController.imageURLs = product.images.items.map { $0.url }
            default:
                guard let urlString = feedItem.previewImageURL, let url = URL(string: urlString) else { break }
                viewController.imageURLs = [url]
            }
        default:
            break
        }
    }

}
