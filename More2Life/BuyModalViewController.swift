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

private let priceFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter
}()

class BuyModalViewController: UIViewController, ApplePaying {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
	@IBOutlet weak var selectionLabel: UILabel!
	@IBOutlet weak var variantPicker: UIPickerView!
    
    var paySession: PaySession?
    var checkoutID: String?
    lazy var paymentComplete: () -> () = { [weak self] in
        self?.checkCompletedOrder()
    }
    
    enum Mode {
        case action(feedItem: FeedItem)
        case donate
    }
    
    @IBOutlet weak var contentView: UIView?
    
    @IBOutlet weak var actionStackView: UIStackView?
    @IBOutlet weak var actionButton: UIButton?
    
    var mode: Mode? {
        didSet {
            guard let mode = mode, case .action(let feedItem) = mode, let listingFeedItem = feedItem as? ListingFeedItem, let product = listingFeedItem.product else { return }
            
            self.product = product
        }
    }
    
    fileprivate var product: ProductViewModel? {
        didSet {
            variant = product?.variants.items.first
        }
    }
    
    fileprivate var variant: VariantViewModel? {
        didSet {
            actionButton?.setTitle(variant?.formattedPrice, for: .normal)
			selectionLabel?.text = variant?.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mode = mode else {
            assert(self.mode != nil, "Must set a mode before presenting \(String(describing: self))")
            return
        }
        
        self.mode = mode
        
        switch mode {
        case .donate:
            addApplePayButton(with: .donate)
            actionButton?.setTitle(localizedDonateString, for: .normal)
        case .action(let feedItem):
			productNameLabel.text = "\(feedItem.title ?? "Selection"):"
            
            // Preview image
            if let imageURL = feedItem.previewImageURL {
                FeedItem.previewImage(with: imageURL, for: feedItem, in: Shared.viewContext) { [weak self] image, request in
                    if Thread.isMainThread {
                        self?.productImageView?.image = image
                    } else {
                        DispatchQueue.main.async {
                            self?.productImageView?.image = image
                        }
                    }
                }
            }
            
            addApplePayButton(with: feedItem.applePayButtonType)
            
            if let feedItem = feedItem as? ListingFeedItem {
                actionButton?.setTitle(feedItem.price, for: .normal)
            } else {
                actionButton?.setTitle(feedItem.type.localizedConfirmationTitle, for: .normal)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkCompletedOrder()
    }
    
    @objc
    private func applePayTapped() {
        guard let product = product, let variant = variant else { return }
        
        Client.shared.createCheckout(with: [CartItem(product: product, variant: variant)]) { [weak self] checkout in
            guard let checkout = checkout else { return }
            DispatchQueue.main.async {
                self?.authorizePaymentWith(checkout)
            }
        }
        
    }
    
    @IBAction func actionTapped() {
        guard let product = product, let variant = variant else { return }
        
        Client.shared.createCheckout(with: [CartItem(product: product, variant: variant)]) { [weak self] checkout in
            guard let checkout = checkout else { return }
            DispatchQueue.main.async {
                self?.openSafariFor(checkout)
            }
        }
        
    }
    
    func addApplePayButton(with type: PKPaymentButtonType) {
        guard PKPaymentAuthorizationViewController.canMakePayments() else { return }
        let applePayButton = PKPaymentButton(type: type, style: .black)
        applePayButton.addTarget(self, action: #selector(applePayTapped), for: .touchUpInside)
        applePayButton.heightAnchor.constraint(equalToConstant: 49).isActive = true
        actionStackView?.insertArrangedSubview(applePayButton, at: 0)
    }
    
    func checkCompletedOrder() {
        guard let checkoutID = checkoutID else { return }
        Client.shared.fetchCompletedOrder(for: checkoutID) { [weak self] orderID in
            guard orderID != nil else { return }
            DispatchQueue.main.async {
                let alert = UIAlertController(title: NSLocalizedString("Thanks for helping the cause!", comment: "Thanks for helping the cause!"), message: NSLocalizedString("Check your email for order details.", comment: "Check your email for order details."), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay"), style: .default, handler: { _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension BuyModalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return product?.variants.items.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return product?.variants.items[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        variant = product?.variants.items[row]
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
    
    fileprivate var priceLabelString: String? {
        switch self {
        case let item as ListingFeedItem:
            return item.price
        default:
            return NSLocalizedString("Thank you for donating!", comment: "Thank you for donating message")
        }
    }
}

extension VariantViewModel {
    fileprivate var formattedPrice: String? {
        return priceFormatter.string(from: price as NSNumber)
    }
}
