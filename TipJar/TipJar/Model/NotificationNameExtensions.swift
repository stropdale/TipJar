//
//  NotificationNameExtensions.swift
//  Weight
//
//  Created by Richard Stockdale on 25/01/2019.
//  Copyright © 2019 Junction Seven. All rights reserved.
//

import Foundation


// MARK: - Tip Jar Related Notifications
extension Notification.Name {
    
    // Observe to be notified when product details have been downloaded
    static let InAppPurchaseProductsDidLoad = Notification.Name("InAppPurchaseProductsDidLoad")
    
    // Observe to be notified when a purchase completes.
    static let InAppPurchaseCompleted = Notification.Name("InAppPurchaseCompleted")
    
    // Observe to be notified when a purchase fails to complete.
    static let InAppPurchaseFailed = Notification.Name("InAppPurchaseFailed")
}
