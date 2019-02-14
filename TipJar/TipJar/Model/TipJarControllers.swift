//
//  TipJarController.swift
//  Weight
//
//  Created by Richard Stockdale on 16/01/2019.
//  Copyright © 2019 Junction Seven. All rights reserved.
//

import Foundation
import StoreKit

@objc class TipJarTransactionController: NSObject {
    
    @objc public static let shared = TipJarTransactionController()

    // MARK: - Product Identifers
    
    //Add product identiers below, then add them to the productIdentifiers set
    @objc public static let item1 = "com.xxx.item1"
    @objc public static let item2 = "com.xxx.item2"
    @objc public static let item3 = "com.xxx.item3"
    
    @objc public static let productIdentifiers: Set<String> = [item1,
                                                         item2,
                                                         item3 ]
    
    private var purchasedProductIdentifiers: Set<String> = []
    
    // MARK: - Fetch Request Initialisation
    
    public typealias ProductsFetchCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
    private var productsFetchCompletionHandler: ProductsFetchCompletionHandler?
    private var productsRequest: SKProductsRequest?
    
    @objc public var products: [SKProduct]?
    
    @objc static public var canMakePurchases: Bool {
        get {
            return SKPaymentQueue.canMakePayments()
        }
    }
    
    override init() {
        super.init()
        loadLocalPurchaseInformation()
        SKPaymentQueue.default().add(self)
    }
    
    private func loadLocalPurchaseInformation() {
        for productIdentifier in TipJarTransactionController.productIdentifiers {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
            }
        }
    }
    
    @objc public func fetchProducts(completionHandler: @escaping ProductsFetchCompletionHandler) {
        productsRequest?.cancel()
        productsFetchCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: TipJarTransactionController.productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    @objc public func getProductForIdentifier(id: String) -> SKProduct? {
        guard let products = products else {
            return nil
        }
        
        for product in products {
            if product.productIdentifier == id {
                return product
            }
        }
        
        return nil
    }
}

// MARK: - Purchasing

extension TipJarTransactionController {
    @objc public func purchaseProduct(_ product: SKProduct) {        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - SKProductsRequestDelegate

extension TipJarTransactionController: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        products = response.products
        productsFetchCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products! {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
        
        // Notification
        NotificationCenter.default.post(name: Notification.Name.InAppPurchaseProductsDidLoad, object: nil)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsFetchCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsFetchCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension TipJarTransactionController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
            deliverPurchaseFailedNotification(reason: localizedDescription)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .InAppPurchaseCompleted, object: identifier)
    }
    
    private func deliverPurchaseFailedNotification(reason: String?) {
        guard let reason = reason else { return }
       
        NotificationCenter.default.post(name: .InAppPurchaseFailed, object: reason)
    }
}
