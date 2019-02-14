//
//  TipJarViewController.swift
//  TipJar
//
//  Created by Richard Stockdale on 16/01/2019.
//  Copyright © 2019 JunctionSeven. All rights reserved.
//

import UIKit

class TipJarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tipJarFetchController = TipJarTransactionController.shared
        tipJarFetchController.fetchProducts { (success, products) in
            
            // Use the returned data to populate your UI
            
            // When the user selects an item, get its SKProduct and request the purchase via purchaseProduct()
        }
    }
}
