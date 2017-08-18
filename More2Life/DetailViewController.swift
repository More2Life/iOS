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

class DetailViewController: UIViewController, FeedDetailing {
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var priceView: UIView?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var playButton: UIButton?
    
    @IBOutlet weak var actionStackView: UIStackView?
    @IBOutlet weak var actionButton: UIButton?
    
    var feedItem: FeedItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = feedItem?.type.localizedDescription
        titleLabel?.text = feedItem?.title
        descriptionLabel?.text = feedItem?.itemDescription
        actionButton?.setTitle(feedItem?.type.localizedCallToActionTitle, for: .normal)
        priceView?.isHidden = true
        
        guard let feedItem = feedItem else { return }
        
        // Preview image
        if let imageURL = (feedItem as? ImagePreviewable)?.previewImageURL {
            FeedItem.previewImage(with: imageURL as NSString) { [weak self] image, request in
                if Thread.isMainThread {
                    self?.previewImageView?.image = image
                } else {
                    DispatchQueue.main.async {
                        self?.previewImageView?.image = image
                    }
                }
            }
        }
        
        switch feedItem {
        case _ as EventFeedItem:
            break
        case let feedItem as ListingFeedItem:
            actionStackView?.addArrangedSubview(PKPaymentButton(type: .buy, style: .black))
            actionButton?.isHidden = true
            
            if let price = feedItem.formattedPrice {
                priceView?.isHidden = false
                priceLabel?.text = price
            }
        case _ as VideoFeedItem:
            actionStackView?.addArrangedSubview(PKPaymentButton(type: .donate, style: .black))
            actionButton?.isHidden = true
            break
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
        default:
            break
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
