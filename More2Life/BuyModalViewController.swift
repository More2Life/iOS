//
//  BuyModalViewController.swift
//  More2Life
//
//  Created by Brendan Kingsford on 8/28/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Shared
import PassKit
import AVKit
import AVFoundation
import Pay
import Storefront

class BuyModalViewController: UIViewController, ApplePaying {
    
    var paySession: PaySession?
    
    enum Mode {
        case action(feedItem: FeedItem)
        case donate
    }
    
    @IBOutlet weak var contentView: UIView?
    
    @IBOutlet weak var actionStackView: UIStackView?
    @IBOutlet weak var actionButton: UIButton?
    
    var mode: Mode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mode = mode else {
            assert(self.mode != nil, "Must set a mode before presenting \(String(describing: self))")
            return
        }
        
        switch mode {
        case .donate:
            addApplePayButton(with: .donate)
            actionButton?.setTitle(localizedDonateString, for: .normal)
        case .action(let feedItem):
            addApplePayButton(with: feedItem.applePayButtonType)
            actionButton?.setTitle(feedItem.type.localizedConfirmationTitle, for: .normal)
        }
    }
    
    @objc
    private func applePayTapped() {
        guard let mode = mode, case .action(let feedItem) = mode, let listingFeedItem = feedItem as? ListingFeedItem, let product = Client.shared.products[listingFeedItem.productID], let variant = product.variants.items.first else { return }
        
        Client.shared.createCheckout(with: [CartItem(product: product, variant: variant)]) { checkout in
            guard let checkout = checkout else { return }
            self.authorizePaymentWith(checkout)
        }
        
    }
    
    func addApplePayButton(with type: PKPaymentButtonType) {
        guard PKPaymentAuthorizationViewController.canMakePayments() else { return }
        let applePayButton = PKPaymentButton(type: type, style: .black)
        applePayButton.addTarget(self, action: #selector(applePayTapped), for: .touchUpInside)
        actionStackView?.insertArrangedSubview(applePayButton, at: 0)
    }
}

extension FeedItem {
    fileprivate var applePayButtonType: PKPaymentButtonType {
        switch self {
        case _ as ListingFeedItem:
            return .buy
        default:
            return .donate
        }
    }
}
