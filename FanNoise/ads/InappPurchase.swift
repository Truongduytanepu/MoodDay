import UIKit
import Foundation
import SVProgressHUD
import StoreKit
import SwiftyStoreKit

public enum ProductID {
    static let keyyearly = "com.airhorn.subyear"
    static let keyweekly = "com.airhorn.subweek"
}

public struct PremiumUser {
    static var isPremium = false
}

class InappPurchase: NSObject {
    static let sharedSecret = "3395447cd6ac436091168f870c853572"
    static func checkStoreKit() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    break
                // Unlock
                case .failed, .purchasing, .deferred:
                    break // do nothing
                
                }
            }
        }
    }
    
    static func verifyReceipt() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("success:\n\(encryptedReceipt)")
            case .error(let error):
                print("failed: \(error)")
            }
        }
    }
    
    static func verifyGroupSubs(completion: @escaping (Bool, VerifySubscriptionResult?) -> ()) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productIds = Set([ProductID.keyweekly, ProductID.keyyearly])
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                completion(true, purchaseResult)
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productIds)")
                }
                
            case .error(let error):
                completion(false, nil)
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    static func verifyPurchase(productId: String, completion: @escaping (Bool, VerifyPurchaseResult?) -> ()) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = productId
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                completion(true, purchaseResult)
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(false, nil)
            }
        }
    }
    
    static func verifySubscription(productId: String, subsType: SubscriptionType, completion: @escaping (Bool, VerifySubscriptionResult?) -> () ) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = productId
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: subsType,  //.autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)
                completion(true, purchaseResult)
            case .error(let error):
                print("failed: \(error)")
                completion(false, nil)
            }
        }
    }
    
    static func purchase(productID: String, atomically: Bool, completion: @escaping (_ isSuccess: Bool, _ errorPurchase: SKError?) -> ()) {
        
        SVProgressHUD.show()
        
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: atomically) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let product):
                do {
                    print("qqqqqq1",product.originalTransaction as Any)
                    print("qqqqqq2",product.transaction)
                    print("qqqqqq3",product.productId)
                    print("qqqqqq4",product.product.contentVersion)
                    print("qqqqqq5",product.product.localizedDescription)
                    print("qqqqqq6",product.product.localizedPrice ?? "1")
                    print("qqqqqq7",product.product.localizedTitle)
                    print("qqqqqq8",product.originalTransaction.debugDescription)
                    print("qqqqqq9",product.product.price)
                    
                }catch let error {
                    print(error.localizedDescription)
                }
                
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                
                completion(true, nil)
            case .error(let error):
                completion(false, error)
            }
        }
    }
    
    static func unlockContent() {
        PremiumUser.isPremium = true
    }
}
