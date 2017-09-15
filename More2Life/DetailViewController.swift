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

class DetailViewController: UIViewController, FeedDetailing {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var playButton: UIButton?
    
    @IBOutlet weak var actionStackView: UIStackView?
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var actionGradientView: UIView?
    
    var feedItem: FeedItem?
    
    var paySession: PaySession?
	
	var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = feedItem?.type.localizedDescription
        titleLabel?.text = feedItem?.title
        if let data = (feedItem?.itemDescription ?? "").data(using: .utf8) {
            do {
                let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
                
                descriptionLabel?.text = attributedString.string
            } catch {
                descriptionLabel?.text = feedItem?.itemDescription
            }
        } else {
            descriptionLabel?.text = feedItem?.itemDescription
        }
        actionButton?.setTitle(feedItem?.type.localizedCallToActionTitle, for: .normal)
        playButton?.isHidden = true
        
        guard let feedItem = feedItem else { return }
        
        switch feedItem {
        case _ as EventFeedItem:
            break
        case let feedItem as ListingFeedItem:
            if let price = feedItem.price {
                actionButton?.setTitle(price, for: .normal)
            }
        case let feedItem as StoryFeedItem:
            if feedItem.videoURL != nil {
                playButton?.isHidden = false
            }
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView?.contentInset = UIEdgeInsets(top: scrollView?.contentInset.top ?? 0, left: 0, bottom: (actionStackView?.frame.height ?? 0) + (16 * 2) + (tabBarController?.tabBar.frame.height ?? 0), right: 0)
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        guard let feedItem = feedItem else { return }
        switch feedItem {
        case let feedItem as EventFeedItem:
            guard let eventURLString = feedItem.eventURL, let url = URL(string: eventURLString) else { break }
            
            present(SFSafariViewController(url: url), animated: true, completion: nil)
		case let feedItem as ListingFeedItem:
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let buyModalViewController: BuyModalViewController = storyboard.instantiateViewController()
			
			self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: buyModalViewController)
			
			buyModalViewController.modalPresentationStyle = .custom
			buyModalViewController.transitioningDelegate = self.halfModalTransitioningDelegate
            buyModalViewController.mode = .action(feedItem: feedItem)
			
			present(buyModalViewController, animated: true, completion: nil)
        default:
            break
        }
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
