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
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var priceView: UIView?
    @IBOutlet weak var priceLabel: UILabel?
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
        descriptionLabel?.text = feedItem?.itemDescription
        actionButton?.setTitle(feedItem?.type.localizedCallToActionTitle, for: .normal)
        priceView?.isHidden = true
        playButton?.isHidden = true
        
        guard let feedItem = feedItem else { return }
        
        // Preview image
        if let imageURL = feedItem.previewImageURL {
            FeedItem.previewImage(with: imageURL as NSString, for: feedItem, in: Shared.viewContext) { [weak self] image, request in
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
            let applePayButton = PKPaymentButton(type: .buy, style: .black)
            applePayButton.addTarget(self, action: #selector(applePayTapped), for: .touchUpInside)
            actionStackView?.insertArrangedSubview(applePayButton, at: 0)
            
            if let price = feedItem.formattedPrice {
                priceView?.isHidden = false
                priceLabel?.text = price
            }
        case let feedItem as StoryFeedItem:
            actionStackView?.insertArrangedSubview(PKPaymentButton(type: .donate, style: .black), at: 0)
            actionButton?.isHidden = true
            
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
    
    @objc
    private func applePayTapped() {
        guard let feedItem = feedItem as? ListingFeedItem, let price = feedItem.product?.price else { return }
        
        let session = PaySession(checkout: PayCheckout(id: UUID().uuidString, lineItems: [PayLineItem(price: Decimal(price), quantity: 1)], discount: nil, shippingAddress: nil, shippingRate: nil, subtotalPrice: Decimal(price), needsShipping: true, totalTax: 0, paymentDue: Decimal(price)), currency: PayCurrency(currencyCode: "USD", countryCode: "US"), merchantID: "merchant.com.coachkalani.shopify")
        session.delegate = self
        session.authorize()
        
        paySession = session
    }
    
    @IBAction func actionTapped(_ sender: UIButton) {
        guard let feedItem = feedItem else { return }
        switch feedItem {
        case let feedItem as EventFeedItem:
            guard let eventURLString = feedItem.eventURL, let url = URL(string: eventURLString) else { break }
            
            present(SFSafariViewController(url: url), animated: true, completion: nil)
		case let feedItem as ListingFeedItem:
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let buyModalViewController = storyboard.instantiateViewController(withIdentifier: "BuyModalViewController")
			
			self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: buyModalViewController)
			
			buyModalViewController.modalPresentationStyle = .custom
			buyModalViewController.transitioningDelegate = self.halfModalTransitioningDelegate
			
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
        default:
            break
        }
    }

}

extension DetailViewController: PaySessionDelegate {
    /// This callback is invoked if the user updates the `shippingContact` and the current address used for shipping is invalidated.
    /// You should make any necessary API calls to obtain shipping rates here and provide an array of `PayShippingRate` objects.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///     - address:    A partial address that you can use to obtain relevant shipping rates. This address is missing `addressLine1` and `addressLine2`. This information is only available after the user has authorized payment.
    ///     - checkout:   The current checkout state.
    ///     - provide:    A completion handler that **must** be invoked with an updated `PayCheckout` and an array of `[PayShippingRate]`. If the `PayPostalAddress` is invalid or you were unable to obtain shipping rates, then returning `nil` or empty shipping rates will result in an invalid address error in Apple Pay.
    ///
    public func paySession(_ paySession: Pay.PaySession, didRequestShippingRatesFor address: Pay.PayPostalAddress, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?, [Pay.PayShippingRate]) -> Swift.Void) {
        
    }
    
    /// This callback is invoked if the user updates the `shippingContact` and the current address is invalidated. This method is called *only* for
    /// checkouts that don't require shipping.
    /// You should make any necessary API calls to update the checkout with the provided address in order to obtain accurate tax information.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///     - address:    A partial address that you can use to obtain relevant tax information for the checkout. This address is missing `addressLine1` and `addressLine2`. This information is only available after the user has authorized payment.
    ///     - checkout:   The current checkout state.
    ///     - provide:    A completion handler that **must** be invoked with an updated `PayCheckout`. Returning `nil` will result in a generic failure in the Apple Pay dialog.
    ///
    public func paySession(_ paySession: Pay.PaySession, didUpdateShippingAddress address: Pay.PayPostalAddress, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?) -> Swift.Void) {
        
    }
    
    /// This callback is invoked when the user selects a shipping rate or an initial array of shipping rates is provided. In the latter case, the first shipping rate in the array will be used. You should make any necessary API calls to update the checkout with the selected shipping rate here.
    ///
    /// - parameters:
    ///     - paySession:   The session that invoked the callback.
    ///     - shippingRate: The selected shipping rate.
    ///     - checkout:     The current checkout state.
    ///     - provide:      A completion handler that **must** be invoked with an updated `PayCheckout`. Returning `nil` will result in a generic failure in the Apple Pay dialog.
    ///
    public func paySession(_ paySession: Pay.PaySession, didSelectShippingRate shippingRate: Pay.PayShippingRate, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?) -> Swift.Void) {
        
    }
    
    /// This callback is invoked when the user authorizes payment using Touch ID or passcode. You should make necessary API calls to update and complete the checkout with final information here (eg: billing address).
    ///
    /// - parameters:
    ///     - paySession:          The session that invoked the callback.
    ///     - authorization:       Authorization object that encapsulates the token and other relevant information: billing address, complete shipping address, and shipping rate.
    ///     - checkout:            The current checkout state.
    ///     - completeTransaction: A completion handler that **must** be invoked with the final transaction status.
    ///
    public func paySession(_ paySession: Pay.PaySession, didAuthorizePayment authorization: Pay.PayAuthorization, checkout: Pay.PayCheckout, completeTransaction: @escaping (Pay.PaySession.TransactionStatus) -> Swift.Void) {
        
    }
    
    /// This callback is invoked when the Apple Pay authorization controller is dismissed.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///
    public func paySessionDidFinish(_ paySession: Pay.PaySession){
        
    }

    
}
