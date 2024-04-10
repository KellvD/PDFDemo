//
//  CDTabBarViewController.swift
//  MyBox
//
//  Created by changdong  on 2020/6/29.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import Photos
import GoogleMobileAds
//import Lottie
class CDTabBarViewController: UITabBarController {
    private lazy var addMediaAlert: CDAddMediaView = {
        let alert = CDAddMediaView(selfType: .tab) {[weak self] type in
            guard let self = self else {
                return
            }
            if type == 0 {
                self.hiddenPhotoClick()
            } else if type == 1 {
                self.mutiWebClick()
            }
        }
        CDSignalTon.shared.makeRewardedAd { _ in}

        UIDevice.keyWindow().addSubview(alert)
        return alert
    }()
    
    lazy var guaideView: CDGuidedPaymentView = {
        let guaideView = CDGuidedPaymentView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        UIDevice.keyWindow().addSubview(guaideView)
        UIDevice.keyWindow().bringSubviewToFront(guaideView)
        return guaideView
    }()

    private var stackview: UIStackView!
    private var myBar :UIView!
    private var lastSelectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = true
        self.tabBar.frame = .zero

        myBar = UIView(frame: CGRect(x: 0, y: self.view.height - BottomBarHeight, width: CDSCREEN_WIDTH, height: BottomBarHeight))
        myBar.backgroundColor = .white
        view.addSubview(myBar)
        view.bringSubviewToFront(myBar)
        stackview = UIStackView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: 48))
        stackview.distribution = .fillEqually
        stackview.alignment = .fill
        myBar.addSubview(stackview)
        
        addChildViewControll(vc: CDAblumViewController(), imageName: "相册_normal", selectImageName: "相册_select", jsonName: "Album")
        addChildViewControll(vc: CDWebViewController(), imageName: "Tab4-Normal", selectImageName: "Tab4-Select", jsonName: "Website")
        addChildViewControll(vc: CDFolderViewController(), imageName: "File-normal", selectImageName: "File-select", jsonName: "File")

        addChildViewControll(vc: CDMineViewController(), imageName: "Tab5-Normal", selectImageName: "Tab5-Select", jsonName: "Setting")

        
        let button = UIButton(type: .custom)
        button.setImage("Tab3".image, for: .normal)
        button.size = CGSize(width: 48, height: 48)
        button.tag = stackview.arrangedSubviews.count
        button.addTarget(target, action: #selector(buttonAction), for: .touchUpInside)
        button.tag = 100
        stackview.insertArrangedSubview(button, at: 2)

        if let button = stackview.arrangedSubviews.first as? UIButton {
            button.isSelected = true
        }
    }
    
    
    private func addChildViewControll(vc: UIViewController, imageName: String, selectImageName: String, jsonName: String){
        let button = UIButton(type: .custom)
        button.setImage(imageName.image, for: .normal)
        button.size = CGSize(width: 48, height: 48)
        button.setImage(selectImageName.image, for: .selected)
        button.tag = stackview.arrangedSubviews.count
        button.addTarget(target, action: #selector(buttonAction), for: .touchUpInside)
        let naVC = CDNavigationController(rootViewController: vc)
        stackview.addArrangedSubview(button)
        addChild(naVC)
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        set {
            myBar.isHidden = newValue
            if !newValue {
                self.tabBar.isHidden = true
                self.tabBar.frame = .zero
            }
        }
        get {
            return myBar.isHidden
        }
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        for i in 0..<stackview.arrangedSubviews.count {
            let button = stackview.arrangedSubviews[i] as! UIButton
            button.isSelected = false
        }
        
        if sender.tag == 100 {
            self.addMediaAlert.pop()
            UIDevice.keyWindow().bringSubviewToFront(self.addMediaAlert)
            if lastSelectIndex == 0 {
                let button = stackview.arrangedSubviews[lastSelectIndex] as! UIButton
                button.isSelected = true
            } else if lastSelectIndex == 3 || lastSelectIndex == 4 {
                let button = stackview.arrangedSubviews[lastSelectIndex + 1] as! UIButton
                button.isSelected = true
            }
            
        } else {
            sender.isSelected = true
            lastSelectIndex = sender.tag
            self.selectedIndex = sender.tag
        }
        

    }

}


extension CDTabBarViewController {
    
    private func mutiWebClick() {
        func addNewPage() {
            let vc = CDWebPageViewController()
            vc.isAdd = true
            vc.hidesBottomBarWhenPushed = true
            if let nav = self.children[selectedIndex] as? CDNavigationController {
                nav.pushViewController(vc, animated: true)
            }
        }
        
        if CDSignalTon.shared.vipType == .not{
            self.guidedPayment {
                addNewPage()
            }
            return
        }else {
            addNewPage()
        }
       
    }
    
    func presentVip() {
        let vc = CDVipViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.cancelHandler = {
            if CDSignalTon.shared.vipType == .not {
                DispatchQueue.main.async {
                    if let rewardedAd = CDSignalTon.shared.interstitiaAd {
    //                    rewardedAd.fullScreenContentDelegate = self
                        rewardedAd.present(fromRootViewController: self)
                        CDSignalTon.shared.makeInterstitialAd { _ in}
                    }
                }
            }
        }
        self.present(vc, animated: true)
    }
    
    func guidedPayment(complete: @escaping(()->Void)) {
        if CDSignalTon.shared.rewardAdsCount >= 5 {
            self.presentVip()
            return
        }
        
        self.guaideView.showPopView()
        guaideView.actionHandler = {[weak self] in
            guard let self = self else { return }
            self.startRewardAdsSdk(complete: complete)

        }
    }
    
    func startRewardAdsSdk(complete: @escaping(()->Void)) {
        let request = GADRequest()
        #if DEBUG
        let id = "ca-app-pub-3940256099942544/1712485313"
        #else
        let id = "ca-app-pub-6968510103744100/3946571521"
        #endif
        GADRewardedAd.load(withAdUnitID: id,
                           request: request,
                           completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                complete()
                return
            }
            DispatchQueue.main.async {
                ad!.present(fromRootViewController: self, userDidEarnRewardHandler: {})
                UserDefaults.standard.set(Date(), forKey: "LastRewardAdsDate")
                CDSignalTon.shared.rewardAdsCount += 1
                CDConfigFile.setIntValueToConfigWith(key: .rewardAdCount, intValue: CDSignalTon.shared.rewardAdsCount + 1)
                complete()
            }
        })
    }
    
    
    private func hiddenPhotoClick() {
        CDAuthorizationTools.checkPermission(type: .library, presentVC: self) { flag, message in
            if flag {
                let freeCount = CDConfigFile.getIntValueFromConfigWith(key: .library_photo)
                if CDSignalTon.shared.vipType == .not && freeCount >= 1{
                    self.presentVip()
                    return
                }
                
                DispatchQueue.main.async {
                    let config = ZLPhotoConfiguration.default()
                    config.maxSelectCount = 10000
                    config.maxSelectVideoDuration = 60 * 60
                    config.allowEditVideo = false
                    config.allowEditImage = false
                    config.allowTakePhotoInLibrary = false
                    config.allowPreviewPhotos = false
                    let uiconfig = ZLPhotoUIConfiguration.default()
                    uiconfig.showAddPhotoButton = false
                    let ps = ZLPhotoPreviewSheet()

                    ps.selectImageBlock = { [weak self] results, isOriginal in
                        
                        guard let self = self else {
                            return
                        }
                        if CDSignalTon.shared.vipType == .not && freeCount < 2{
                            CDConfigFile.setIntValueToConfigWith(key: .library_photo, intValue: freeCount + 1)
                        }

                        let picker = CDMediaPickerViewController()
                        picker.isMovePicker = false
                        picker.moveHandle = { folder in
                            DispatchQueue.global().async {
                                CDSignalTon.shared.saveMedia(results, folder!)

                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: NSNotification.Name("addMediaSuccess"), object: nil)
                                    let flag = CDConfigFile.getBoolValueFromConfigWith(key: .rate)
                                    if !flag {
                                        CDSignalTon.shared.rataApp(isGoStore: false)
                                        CDConfigFile.setBoolValueToConfigWith(key: .rate, boolValue: true)
                                    }
                                    let sheet = UIAlertController(title: "Import Completed", message: "Your photos has been successfully imported into Hide photos & videos.\n\n Do you want to delete the imported photos from you photo library?", preferredStyle: .alert)
                                    sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                                        CDSignalTon.shared.deleteSystemPhoto(results)
                                    }))
                                    sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                    self.present(sheet, animated: true, completion: nil)
                                }
                            }
                        }
                        self.present(CDNavigationController(rootViewController: picker), animated: true)


                    }
                    ps.showPhotoLibrary(sender: self)
                }
            }
        }
    }

//    func createButton(jsonName: String) -> LottieAnimationView {
//        let starAnimationView = LottieAnimationView(name: jsonName)
////        starAnimationView.translatesAutoresizingMaskIntoConstraints = false
//        starAnimationView.size = CGSize(width: 24, height: 24)
//        starAnimationView.loopMode = .loop
//        starAnimationView.play()
//        starAnimationView.contentMode = .scaleAspectFit
//        starAnimationView.isUserInteractionEnabled = true
////        starAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tabarItemClick)))
//        return starAnimationView
//    }
}
