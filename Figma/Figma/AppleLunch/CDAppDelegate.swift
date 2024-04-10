//
//  AppDelegate.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAnalytics
import SwiftyStoreKit
import GoogleMobileAds
import AppTrackingTransparency
import FBSDKCoreKit
@UIApplicationMain
class CDAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginNav: UINavigationController?
    var isEnterBackground: Bool = false
    var defaultImageView: UIImageView!
    var defaultView: UIView!

    private var openAd: GADAppOpenAd!
    lazy var lockView: CDLockViewController = {
        let lock = CDLockViewController()
        lock.viewType = .lockScreen
        return lock
    }()
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let isFirstInstall = checkFirstInstall()

        _ = CDSignalTon.shared
        _ = CDSqlManager.shared
        FirebaseApp.configure()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = .baseBgColor
        if isFirstInstall {
            self.window?.rootViewController = CDPageViewController()
        } else {
            
            if CDSignalTon.shared.basePwd != nil {
                self.lockView.viewType = .login
                self.window?.rootViewController = self.lockView
            } else {
                if CDSignalTon.shared.vipType == .vip {
                    
                    CDSignalTon.shared.tab = CDTabBarViewController()
                    self.window?.rootViewController = CDSignalTon.shared.tab
                }else {
                    let rooot = CDPageViewController()
                    rooot.isOnlyWeekSub = true
                    self.window?.rootViewController = rooot
                }
            }

        }
    
        handleVip()
        checkIDFA()
        return true
    }
    
    lazy var coverView: UIImageView = {
        let vvv = UIImageView(frame: self.window!.bounds)
        vvv.image = "背景遮挡层".image
        return vvv
    }()
    
    func applicationWillResignActive(_ application: UIApplication) {
        if CDSignalTon.shared.basePwd != nil {
            UIDevice.keyWindow().endEditing(true)
            UIDevice.keyWindow().addSubview(self.coverView)
            UIDevice.keyWindow().bringSubviewToFront(self.coverView)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // 进入后台后的present的view全部dismiss，比如分享，拍照等
//        if CDSignalTon.shared.customPickerView != nil {
//            CDSignalTon.shared.customPickerView.dismiss(animated: true, completion: nil)
//            CDSignalTon.shared.customPickerView = nil
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if CDSignalTon.shared.basePwd != nil {
            UIDevice.keyWindow().addSubview(self.lockView.view)
            UIDevice.keyWindow().bringSubviewToFront(self.lockView.view)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.coverView.removeFromSuperview()
        self.checkVip()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func checkVip(){
        let vipTime = CDConfigFile.getIntValueFromConfigWith(key: .vipDeadLine)
        let current = GetTimestamp(nil)
        if current > vipTime {
            print("购买会员到期了,恢复非会员状态")
            CDSignalTon.shared.vipType = .not
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshVip"), object: nil)
            }
            
        }else {
            CDSignalTon.shared.vipType = .vip

        }
    }
    
    func handleVip(){
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                }
            }
        }
    }
    
    func checkIDFA(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    if status == .authorized {
                        print("广告权限请求完成")
                    }
                })
            }
            
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, options: options)
        return true
    }
}
