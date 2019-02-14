//
//  StoreKitExtensions.swift
//  Weight
//
//  Created by Richard Stockdale on 18/01/2019.
//  Copyright © 2019 Junction Seven. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct {

    /// Returns a price string formatted for the users region
    @objc var formattedPrice: String {
        get {
            let formatter = NumberFormatter()
            
            formatter.formatterBehavior = .behavior10_4
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            
            if let formattedPrice = formatter.string(from: price) {
                return formattedPrice
            }
            
            return "Error getting price"
        }
    }
}
