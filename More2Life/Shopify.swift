//
//  Shopify.swift
//  More2Life
//
//  Created by Porter Hoskins on 9/2/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import Foundation
import Buy
import Pay

private let client = Graph.Client(
    shopDomain: "more2life-foundation.myshopify.com",
    apiKey:     "a6b7e9ddb238920dde5e5223a9466054"
)

private let shopQuery = Storefront.buildQuery { $0
    .shop { $0
        .name()
        .paymentSettings { $0
            .currencyCode()
            .countryCode()
        }
        .collections(first: 10) { $0
            .edges { $0
                .node { $0
                    .id()
                    .title()
                    .products(first: 10) { $0
                        .edges { $0
                            .node { $0
                                .id()
                                .title()
                                .productType()
                                .description()
                                .variants(first: 10) { $0
                                    .edges { $0
                                        .node { $0
                                            .id()
                                            .price()
                                            .title()
                                            .availableForSale()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private let applePayMerchantID = "merchant.com.coachkalani.shopify"

enum ShopifyError: Error {
    case noCheckoutID
    case queryError
}

class Shopify {
    static let shared = Shopify()
    
    fileprivate var paymentSettings: Storefront.PaymentSettings?
    fileprivate var name: String?
    
    fileprivate var checkoutID: GraphQL.ID?
    var paySession: PaySession?
    var paymentCompletion: ((_ error: [Error]?) -> ())?
    
    private init() { }
    
    func setupShop() {
        let task = client.queryGraphWith(shopQuery) { response, _ in
            self.name = response?.shop.name
            self.paymentSettings = response?.shop.paymentSettings
            
            let collections  = response?.shop.collections.edges.map { $0.node }
            collections?.forEach { collection in
                
                let products = collection.products.edges.map { $0.node }
                print(products)
            }
        }
        
        task.resume()
    }
    
    func initiateCheckout(with variantID: String, price: Double, completion: @escaping (_ error: [Error]?) -> ()) {
        // TODO: Remove
        var price = 0.10
        
        
        let input = Storefront.CheckoutCreateInput(lineItems: [Storefront.CheckoutLineItemInput(variantId: GraphQL.ID(rawValue: "Z2lkOi8vc2hvcGlmeS9Qcm9kdWN0VmFyaWFudC80NzM1ODM2NjQwNA=="), quantity: 1)])
        
        let mutation = Storefront.buildMutation { $0
            .checkoutCreate(input: input) { $0
                .checkout { $0
                    .id()
                }
                .userErrors { $0
                    .field()
                    .message()
                }
            }
        }
        
        let task = client.mutateGraphWith(mutation) { result, error in
            guard error == nil else {
                if let error = error {
                    print("\(error.localizedDescription) \(error)")
                }
                
                completion([error ?? ShopifyError.queryError])
                return
            }
            
            if let userErrors = result?.checkoutCreate?.userErrors {
                // handle any user error
                userErrors.forEach { print($0) }
                completion(userErrors)
            }
            
            self.checkoutID = result?.checkoutCreate?.checkout?.id
            
            guard let checkoutID = self.checkoutID, let currencyCode = self.paymentSettings?.currencyCode.rawValue, let countryCode = self.paymentSettings?.countryCode.rawValue else {
                print("Couldn't get checkout ID...")
                completion([ShopifyError.noCheckoutID])
                return
            }

            let session = PaySession(checkout: PayCheckout(id: checkoutID.rawValue, lineItems: [PayLineItem(price: Decimal(price), quantity: 1)], discount: nil, shippingAddress: nil, shippingRate: nil, subtotalPrice: Decimal(price), needsShipping: true, totalTax: 0, paymentDue: Decimal(price)), currency: PayCurrency(currencyCode: currencyCode, countryCode: countryCode), merchantID: applePayMerchantID)
            session.delegate = self
            session.authorize()
            
            self.paySession = session
            self.paymentCompletion = completion
        }
        task.resume()
    }
}

extension Shopify: PaySessionDelegate {
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
        provide(checkout, [PayShippingRate(handle: "l", title: "fedex", price: 1)])
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
        provide(checkout)
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
        provide(checkout)
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
        let payment = Storefront.TokenizedPaymentInput(
            amount:         checkout.paymentDue,
            idempotencyKey: paySession.identifier,
            billingAddress: self.mailingAddressInputFrom(authorization.billingAddress),
            type:           "apple_pay",
            paymentData:    authorization.token
        )
        
        guard let checkoutID = checkoutID else {
            completeTransaction(.failure)
            return
        }
        let mutation = Storefront.buildMutation { $0
            .checkoutCompleteWithTokenizedPayment(checkoutId: checkoutID, payment: payment) { $0
                .payment { $0
                    .id()
                    .ready()
                }
                .checkout { $0
                    .id()
                    .ready()
                }
                .userErrors { $0
                    .field()
                    .message()
                }
            }
        }
        
        let task = client.mutateGraphWith(mutation) { result, error in
            guard error == nil else {
                // handle request error
                completeTransaction(.failure)
                return
            }
            
            if let userError = result?.checkoutCompleteWithTokenizedPayment?.userErrors {
                // handle any user error
                completeTransaction(.failure)
                return
            }
            
            let checkoutReady = result?.checkoutCompleteWithTokenizedPayment?.checkout.ready ?? false
            let paymentReady  = result?.checkoutCompleteWithTokenizedPayment?.payment?.ready ?? false
            
            // checkoutReady == false
            // paymentReady == false
        }
        task.resume()
    }
    
    /// This callback is invoked when the Apple Pay authorization controller is dismissed.
    ///
    /// - parameters:
    ///     - paySession: The session that invoked the callback.
    ///
    public func paySessionDidFinish(_ paySession: Pay.PaySession){
        paymentCompletion?(nil)
    }
    
    func mailingAddressInputFrom(_ billingAddress: PayAddress) -> Storefront.MailingAddressInput {
        return Storefront.MailingAddressInput(address1: billingAddress.addressLine1, address2: billingAddress.addressLine2, city: billingAddress.city, company: nil, country: billingAddress.country, firstName: billingAddress.firstName, lastName: billingAddress.lastName, phone: billingAddress.phone, province: billingAddress.province, zip: billingAddress.zip)
    }
}

extension Storefront.UserError: Error {
    
}
