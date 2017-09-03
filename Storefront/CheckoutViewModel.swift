//
//  CheckoutViewModel.swift
//  Storefront
//
//  Created by Shopify.
//  Copyright (c) 2017 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Buy

public final class CheckoutViewModel: ViewModel {
    
    public typealias ModelType = Storefront.Checkout
    
    public let model:  ModelType
    
    public enum PaymentType: String {
        case applePay   = "apple_pay"
        case creditCard = "credit_card"
    }
    
    public let id:               String
    public let ready:            Bool
    public let requiresShipping: Bool
    public let taxesIncluded:    Bool
    public let shippingAddress:  AddressViewModel?
    public let shippingRate:     ShippingRateViewModel?
    
    public let note:             String?
    public let webURL:           URL
    
    public let lineItems:        [LineItemViewModel]
    public let currencyCode:     String
    public let subtotalPrice:    Decimal
    public let totalTax:         Decimal
    public let totalPrice:       Decimal
    public let paymentDue:       Decimal
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public required init(from model: ModelType) {
        self.model            = model
        
        self.id               = model.id.rawValue
        self.ready            = model.ready
        self.requiresShipping = model.requiresShipping
        self.taxesIncluded    = model.taxesIncluded
        self.shippingAddress  = model.shippingAddress?.viewModel
        self.shippingRate     = model.shippingLine?.viewModel
        
        self.note             = model.note
        self.webURL           = model.webUrl
        
        self.lineItems        = model.lineItems.edges.viewModels
        self.currencyCode     = model.currencyCode.rawValue
        self.subtotalPrice    = model.subtotalPrice
        self.totalTax         = model.totalTax
        self.totalPrice       = model.totalPrice
        self.paymentDue       = model.paymentDue
    }
}

extension Storefront.Checkout: ViewModeling {
    typealias ViewModelType = CheckoutViewModel
}
