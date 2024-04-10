//
//  BuyManager.swift
//  CleanDust
//
//  Created by yankai on 2024/1/16.
//

import UIKit
import SwiftyStoreKit
import TPInAppReceipt
import SwiftyJSON
class BuyManager: NSObject {
    
    static let `default` = BuyManager()
    
    private var receiptInfo: ReceiptInfo? {
        set {
            if let jsonData = try? JSONSerialization.data(withJSONObject: newValue as Any) {
                UserDefaults.standard.set(jsonData, forKey: "BuyManagerReceiptInfoKey")
                UserDefaults.standard.synchronize()
            }
        }
        get {
            if let data = UserDefaults.standard.data(forKey: "BuyManagerReceiptInfoKey"),
               let obj = try? JSON(data: data).dictionary as? ReceiptInfo {
                return obj
            }
            return nil
        }
    }
    
    var inSubscription: Bool {
        
        guard let receipt = try? InAppReceipt.localReceipt() else { return false }
        
        let inAppPurchaseQuarterly = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: IAP_Year, forDate: Date())
        let inAppPurchaseMonthe = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: IAP_Mouth,forDate: Date())
        let inAppPurchaseWeek = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: IAP_Week,forDate: Date())
        
        var valueQuarterly = false
        if let expiryDate = inAppPurchaseQuarterly?.subscriptionExpirationDate {
            let compare = Date().compare(expiryDate)
            valueQuarterly = compare != .orderedDescending
        }
        var valueMonth = false
        if let expiryDate = inAppPurchaseMonthe?.subscriptionExpirationDate {
            let compare = Date().compare(expiryDate)
            valueMonth = compare != .orderedDescending
        }
        var valueWeek = false
        if let expiryDate = inAppPurchaseWeek?.subscriptionExpirationDate {
            let compare = Date().compare(expiryDate)
            valueWeek = compare != .orderedDescending
        }
        let value = valueQuarterly || valueMonth || valueWeek
        return value
    }
    
    func verifyReceipt( completion: @escaping(String) -> Void ) {
        do {
            let receipt = try InAppReceipt.localReceipt()
            do {
                try receipt.verifyHash()
                completion("success")
            } catch IARError.initializationFailed(_) {
                completion("initializationFailed")
            } catch IARError.validationFailed(_) {
                completion("validationFailed")
            } catch IARError.purchaseExpired {
                completion("purchaseExpired")
            } catch {
                completion("unknown error")
            }
        } catch {
            completion("error")
        }
    }

    func loadStoreKit() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    func purchaseProduct(iap: String, itemCount: Int, completion: @escaping (Bool, Data?) -> Void) {
        SwiftyStoreKit.purchaseProduct(iap, quantity: itemCount) { resultInfo in
            DispatchQueue.main.async {
                switch resultInfo {
                case .success:
                    guard let localReceiptData = SwiftyStoreKit.localReceiptData else {
                        completion(false, nil)
                        return
                    }
                    completion(true, localReceiptData)
                    break
                case .error(_):
                    completion(false, nil)
                    break
                }
            }
        }
    }

    func restore(comp: @escaping (String)->()) {
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            guard let `self` = self else { return }
            if results.restoreFailedPurchases.count > 0 {
                comp("Restore Failed")
                debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                //
                for purchase in results.restoredPurchases {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                self.verifyReceipt { text in
                    let status = self.inSubscription
                    if status {
                        comp("Restore Success")
                    } else {
                        comp("Nothing to Restore")
                    }
                }
            } else {
                comp("Nothing to Restore")
            }
        }
    }

}
