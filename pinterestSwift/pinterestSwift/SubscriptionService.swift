//
//  SubscriptionService.swift
//  pinterestSwift
//
//  Created by Luis Gerardo on 06/09/17.
//  Copyright © 2017 Sergio Ivan Lopez Monzon. All rights reserved.
//

import Foundation
import StoreKit

class SubscriptionService: NSObject {
    
    static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
    static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    let productIdentifier = "CocinaMexicanaRecetasFaciles"
    
    static let shared = SubscriptionService()
    
    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }
    
    var currentSessionId: String? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.sessionIdSetNotification, object: currentSessionId)
        }
    }
    
    var currentSubscription: PaidSubscription?
    
    var options: [Subscription]? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.optionsLoadedNotification, object: options)
        }
    }
    
    func loadSubscriptionOptions() {
        let productIdentifiers = Set([productIdentifier])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
    }
    
    func purchase(subscription: Subscription) {
        let payment = SKPayment(product: subscription.product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            SubService.shared.upload(receipt: receiptData) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let result):
                    strongSelf.currentSessionId = result.sessionId
                    strongSelf.currentSubscription = result.currentSubscription
                    completion?(true)
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error)")
                    completion?(false)
                }
            }
        }
    }
    
    private func loadReceipt() -> Data? {
        // TODO: Load the receipt data from the device
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        options = response.products.map({ Subscription(product: $0) })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print(error.localizedDescription)
        }
    }
}
