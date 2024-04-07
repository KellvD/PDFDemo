//
//  NKIAPManager.swift
//  Veflix
//
//  Created by dong chang on 2022/1/20.
//

import UIKit
import SwiftyStoreKit
import SwiftyJSON
import StoreKit

class NKIAPManager: NSObject {
    static var viewController: UIViewController?
    
    class func getPurchaseProductList(retur:@escaping ([CDAppBuyInfo]?) ->Void){
        let set = Set(["com.wenying.securephoto.week","com.wenying.securephoto.year","com.wenying.securephoto.month"])
        SwiftyStoreKit.retrieveProductsInfo(set) { result in
            var arr:[CDAppBuyInfo] = []
            if result.retrievedProducts.count > 0 {
                print("app 内购获取列表成功")
                for product in result.retrievedProducts {
                    let info = CDAppBuyInfo()
                    info.productIdentifier = product.productIdentifier
                    info.price = product.localizedPrice!
                    if info.productIdentifier == "com.wenying.securephoto.week" {
                        info.order = 0
                        info.productName = "Weekly"

                    }else if info.productIdentifier == "com.wenying.securephoto.month" {
                        info.order = 2
                        info.productName = "Monthly"
                    }else{
                        info.order = 1
                        info.productName = "Yearly"

                    }
                    arr.append(info)
                    
                }
                
                let newArr = arr.sorted { I1, I2 in
                    I1.order < I2.order
                }
                
                retur(newArr)
            }else{
                print("app 内购获取列表失败 = \(String(describing: result.error?.localizedDescription))")
                retur(nil)
            }
            
        }
    }
    
    class func purchaseProduct(productIDs: String, complete:@escaping (Bool)->Void){
        SwiftyStoreKit.purchaseProduct(productIDs) { result in
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                #if DEBUG
                verifyReceipt(service: .sandbox, isRestor: false, product_id: purchase.productId, complete: complete)
                #else
                verifyReceipt(service: .production, isRestor: false, product_id: purchase.productId, complete: complete)
                #endif
            }
            complete(false)

            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }

        }
    }
    
    class func restoreProduct(complete:@escaping (Bool)->Void){

        CDHUDManager.shared.showWait()
        if CDSignalTon.shared.vipType == .vip {
            CDHUDManager.shared.hideWait()
            return
        }
        SwiftyStoreKit.restorePurchases(atomically: true, applicationUsername: "") { results in
            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
            }
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
#if DEBUG
                verifyReceipt(service: .sandbox, isRestor: true, product_id: purchase.productId, complete: complete)
#else
                verifyReceipt(service: .production, isRestor: true, product_id: purchase.productId, complete: complete)
#endif
                
            }
            complete(false)
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }
    
    class func caancelProduct(){
//        SwiftyStoreKit.ca
    }
    
    
    class func verifyReceipt(service:AppleReceiptValidator.VerifyReceiptURLType, isRestor: Bool, product_id: String, complete:@escaping (Bool)->Void){
        CDHUDManager.shared.showWait("verify Receipt")
        let receipt = AppleReceiptValidator(service: service, sharedSecret: IAPPubKey)
        SwiftyStoreKit.verifyReceipt(using: receipt) { result in
            DispatchQueue.main.async {
                CDHUDManager.shared.hideWait()
            }
            switch result {
            case .success(let receipt):
                let json = JSON(receipt)
                let status = json["status"].intValue
                if status == 0{
                    print("订单验证成功receipt = \(receipt)")
                    //验证是否过期
                    DispatchQueue.main.async {
                        let in_apps = json["latest_receipt_info"].arrayValue
                        for appJson in in_apps {
                            let expiresTime = appJson["expires_date_ms"].intValue
                            let productId = appJson["product_id"].stringValue
                            let current =  GetTimestamp(nil)
                            if expiresTime > current {
                                print("订单验证OK，过期时间：\(expiresTime),当前时间：\(current)")
                                if isRestor {
                                    CDSignalTon.shared.vipType = .vip
                                    CDConfigFile.setIntValueToConfigWith(key: .vipDeadLine, intValue: expiresTime)
                                    
                                    DispatchQueue.main.async {
                                        CDHUDManager.shared.showText("All features has been unlock!")
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshVip"), object: nil)
                                    }
                                    complete(true)
                                    break
                                }else{
                                    if productId == product_id{
                                        CDSignalTon.shared.vipType = .vip
                                        CDConfigFile.setIntValueToConfigWith(key: .vipDeadLine, intValue: expiresTime)
                                        DispatchQueue.main.async {
                                            CDHUDManager.shared.showText("All features has been unlock!")
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshVip"), object: nil)
                                        }
                                        complete(true)
                                        break
                                    }
                                    
                                }
                            }
                        }
                    }
                }else if status == 21007 {
                    print("订单验证是沙盒模式-继续验证")
                }else if status == 21006{
                    print("收据是有效的，但订阅服务已经过期")
                }else if status == 21003{
                    print("receipt无法通过验证")
                }
                CDHUDManager.shared.hideWait()
                complete(false)

            case .error(let error):
                print("订单验证失败：\(error.localizedDescription)")
                CDHUDManager.shared.hideWait()
                complete(false)
            }
        }
    }
}
