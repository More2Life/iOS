//
//  ApplePaying.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/2/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Pay
import Storefront
import SafariServices

protocol ApplePaying: PaySessionDelegate {
    var paySession: PaySession? { get set }
    var checkoutID: String? { get set }
    var paymentComplete: () -> () { get }
}

extension ApplePaying where Self: UIViewController {
    func openSafariFor(_ checkout: CheckoutViewModel) {
        checkoutID = checkout.id
        
        let safari = SFSafariViewController(url: checkout.webURL)
        safari.navigationItem.title = "Checkout"
        present(safari, animated: true, completion: nil)
    }
    
    func authorizePaymentWith(_ checkout: CheckoutViewModel) {
        checkoutID = checkout.id
        
        let initiatePayment: (_ currencyCode: String, _ countryCode: String) -> () = { currencyCode, countryCode in
            let payCurrency = PayCurrency(currencyCode: currencyCode, countryCode: countryCode)
            let payItems    = checkout.lineItems.map { item in
                PayLineItem(price: item.totalPrice, quantity: item.quantity)
            }
            
            let payCheckout = PayCheckout(
                id:              checkout.id,
                lineItems:       payItems,
                discount:        nil,
                shippingAddress: nil,
                shippingRate:    nil,
                subtotalPrice:   checkout.subtotalPrice,
                needsShipping:   checkout.requiresShipping,
                totalTax:        checkout.totalTax,
                paymentDue:      checkout.paymentDue
            )
            
            let paySession      = PaySession(checkout: payCheckout, currency: payCurrency, merchantID: "merchant.com.coachkalani.shopify")
            paySession.delegate = self
            self.paySession     = paySession
            
            paySession.authorize()
        }
        
        guard let paymentSettings = paymentSettings else {
            Client.shared.fetchPaymentSettings { paymentSettings in
                guard let paymentSettings = paymentSettings else {
                    // TODO: Alert Error
                    return
                }
                More2Life.paymentSettings = paymentSettings
                
                DispatchQueue.main.async {
                    initiatePayment(paymentSettings.currencyCode.rawValue, paymentSettings.countryCode.rawValue)
                }
            }
            
            return
        }
        
        initiatePayment(paymentSettings.currencyCode.rawValue, paymentSettings.countryCode.rawValue)
    }
}

extension ApplePaying where Self: UIViewController {
    /// This callback is invoked if the user updates the `shippingContact` and the current address used for shipping is invalidated.
    /// You should make any necessary API calls to obtain shipping rates here and provide an array of `PayShippingRate` objects.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///     - address:    A partial address that you can use to obtain relevant shipping rates. This address is missing `addressLine1` and `addressLine2`. This information is only available after the user has authorized payment.
    ///     - checkout:   The current checkout state.
    ///     - provide:    A completion handler that **must** be invoked with an updated `PayCheckout` and an array of `[PayShippingRate]`. If the `PayPostalAddress` is invalid or you were unable to obtain shipping rates, then returning `nil` or empty shipping rates will result in an invalid address error in Apple Pay.
    ///
    func paySession(_ paySession: Pay.PaySession, didRequestShippingRatesFor address: Pay.PayPostalAddress, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?, [Pay.PayShippingRate]) -> Swift.Void) {
        print("Updating checkout with address...")
        Client.shared.updateCheckout(checkout.id, updatingShippingAddress: address) { checkout in
            
            guard let checkout = checkout else {
                print("Update for checkout failed.")
                provide(nil, [])
                return
            }
            
            print("Getting shipping rates...")
            Client.shared.fetchShippingRatesForCheckout(checkout.id) { result in
                if let result = result {
                    print("Fetched shipping rates.")
                    provide(result.checkout.payCheckout, result.rates.payShippingRates)
                } else {
                    provide(nil, [])
                }
            }
        }
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
    func paySession(_ paySession: Pay.PaySession, didUpdateShippingAddress address: Pay.PayPostalAddress, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?) -> Swift.Void) {
        print("Updating checkout with shipping address for tax estimate...")
        Client.shared.updateCheckout(checkout.id, updatingShippingAddress: address) { checkout in
            
            if let checkout = checkout {
                provide(checkout.payCheckout)
            } else {
                print("Update for checkout failed.")
                provide(nil)
            }
        }
    }
    
    /// This callback is invoked when the user selects a shipping rate or an initial array of shipping rates is provided. In the latter case, the first shipping rate in the array will be used. You should make any necessary API calls to update the checkout with the selected shipping rate here.
    ///
    /// - parameters:
    ///     - paySession:   The session that invoked the callback.
    ///     - shippingRate: The selected shipping rate.
    ///     - checkout:     The current checkout state.
    ///     - provide:      A completion handler that **must** be invoked with an updated `PayCheckout`. Returning `nil` will result in a generic failure in the Apple Pay dialog.
    ///
    func paySession(_ paySession: Pay.PaySession, didSelectShippingRate shippingRate: Pay.PayShippingRate, checkout: Pay.PayCheckout, provide: @escaping (Pay.PayCheckout?) -> Swift.Void) {
        print("Selecting shipping rate...")
        Client.shared.updateCheckout(checkout.id, updatingShippingRate: shippingRate) { updatedCheckout in
            print("Selected shipping rate.")
            provide(updatedCheckout?.payCheckout)
        }
    }
    
    /// This callback is invoked when the user authorizes payment using Touch ID or passcode. You should make necessary API calls to update and complete the checkout with final information here (eg: billing address).
    ///
    /// - parameters:
    ///     - paySession:          The session that invoked the callback.
    ///     - authorization:       Authorization object that encapsulates the token and other relevant information: billing address, complete shipping address, and shipping rate.
    ///     - checkout:            The current checkout state.
    ///     - completeTransaction: A completion handler that **must** be invoked with the final transaction status.
    ///
    func paySession(_ paySession: Pay.PaySession, didAuthorizePayment authorization: Pay.PayAuthorization, checkout: Pay.PayCheckout, completeTransaction: @escaping (Pay.PaySession.TransactionStatus) -> Swift.Void) {
        guard let email = authorization.shippingAddress.email else {
            print("Unable to update checkout email. Aborting transaction.")
            completeTransaction(.failure)
            return
        }
        
        print("Updating checkout email...")
        Client.shared.updateCheckout(checkout.id, updatingEmail: email) { updatedCheckout in
            
            guard let _ = updatedCheckout else {
                completeTransaction(.failure)
                return
            }
            
            print("Checkout email updated: \(email)")
            print("Updating shipping address. \(authorization.shippingAddress)")
            Client.shared.updateCheckout(checkout.id, updatingShippingAddress: authorization.shippingAddress) { updatedCheckout in
                guard let _ = updatedCheckout else {
                    completeTransaction(.failure)
                    return
                }
                
                print("Checkout shipping address updated: \(authorization.shippingAddress)")
                print("Completing checkout...")
                
                Client.shared.completeCheckout(checkout, billingAddress: authorization.billingAddress, applePayToken: authorization.token, idempotencyToken: paySession.identifier) { payment in
                    if let payment = payment, checkout.paymentDue == payment.amount {
                        print("Checkout completed successfully.")
                        completeTransaction(.success)
                    } else {
                        print("Checkout failed to complete.")
                        completeTransaction(.failure)
                    }
                }
            }
        }
    }
    
    /// This callback is invoked when the Apple Pay authorization controller is dismissed.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///
    func paySessionDidFinish(_ paySession: Pay.PaySession) {
        paymentComplete()
    }
}
