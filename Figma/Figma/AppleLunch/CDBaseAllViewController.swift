//
//  CDBaseAllViewController.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit
import GoogleMobileAds

extension CDBaseAllViewController {
    public typealias CDDocumentPickerCompleteHandler = (_ success: Bool) -> Void
}

class CDBaseAllViewController:
UIViewController, UIGestureRecognizerDelegate, UIDocumentPickerDelegate {

    var popBtn = UIButton()
    var tmpFolderInfo: CDSafeFolder!
    var addBtn = UIButton()
    private var isMobileAdsStartCalld = false

    open var docuemntPickerComplete: CDDocumentPickerCompleteHandler?
    var alert: UIAlertController?
    
    lazy var vipVC: CDVipViewController = {
        let vc = CDVipViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.cancelHandler = {
            self.startInterstitialAdsSdk(true)
        }
        return vc
    }()
    
    lazy var bannerView: GADBannerView = {
        let vv = GADBannerView(adSize: GADAdSizeBanner)
        vv.adUnitID = "ca-app-pub-6968510103744100/5259653199"
        vv.delegate = self
        startBannerAdsSdk()

        return vv
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tabBarController?.hidesBottomBarWhenPushed = true
        self.tabBarController?.tabBar.isHidden = true

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        addBtn = UIButton(type: .custom)
        addBtn.frame = CGRect(x: CDSCREEN_WIDTH / 2.0 - 176/2.0, y: CDViewHeight - 48 - BottomBarHeight, width: 176, height: 48)
        addBtn.addTarget(self, action: #selector(onAddDataAction), for: .touchUpInside)
        view.addSubview(addBtn)
        addBtn.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVip), name: NSNotification.Name(rawValue: "refreshVip"), object: nil)
    }
    
    @objc func refreshVip(){}
  
    @objc func onAddDataAction() {}

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func presentDocumentPicker(documentTypes: [String]) {
//        UIDocumentPickerViewController
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        if #available(iOS 11, *) {
            documentPicker.allowsMultipleSelection = true
        }
        CDSignalTon.shared.customPickerView = documentPicker
        self.present(documentPicker, animated: true, completion: nil)
    }

    // MARK: UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        CDSignalTon.shared.customPickerView = nil
        var index = 0
        var errorArr: [String] = []
        func handleAllDocumentPickerFiles(urlArr: [URL]) {
            DispatchQueue.global().async {
                var tmpUrlArr = urlArr
                if urlArr.count > 0 {
                    index += 1
                    let subUrl = urlArr.first!
                    let fileUrlAuthozied = subUrl.startAccessingSecurityScopedResource()
                    if fileUrlAuthozied {
                        let fileCoordinator = NSFileCoordinator()

                        fileCoordinator.coordinate(readingItemAt: subUrl, options: [], error: nil) {[weak self] (newUrl) in
                            guard let self = self else {
                                return
                            }
                            do {
                                let fileSize = try Data(contentsOf: newUrl).count
                                if fileSize > getDiskSpace().free {
                                    DispatchQueue.main.async {
                                        self.alertSpaceWarn()
                                        CDHUDManager.shared.hideProgress()
                                        return
                                    }
                                } else {
                                    CDSignalTon.shared.saveFileWithUrl(fileUrl: newUrl, folderInfo: self.tmpFolderInfo)
                                    tmpUrlArr.removeFirst()
                                    handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                                }
                            } catch {
                                errorArr.append(subUrl.absoluteString)
                                CDPrintManager.log("文件导入失败:\(error.localizedDescription)", type: .ErrorLog)
                                tmpUrlArr.removeFirst()
                                handleAllDocumentPickerFiles(urlArr: tmpUrlArr)
                                return
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        CDHUDManager.shared.updateProgress(num: Float(index)/Float(urls.count), text: "\(index)/\(urls.count)")
                    }
                } else {
                    DispatchQueue.main.async {
                        CDHUDManager.shared.hideProgress()
                        if errorArr.count == 0 {
                            CDHUDManager.shared.showComplete("Done")
                        } else {
                            CDHUDManager.shared.showComplete("A part of files import faulure")
                        }

                        self.docuemntPickerComplete?(true)
                    }
                }
            }

        }
        handleAllDocumentPickerFiles(urlArr: urls)
        CDHUDManager.shared.showProgress("Start import")
    }

    // 分享
    func presentShareActivityWith(dataArr: [NSObject], Complete:@escaping(_ error: Error?) -> Void) {

        let activityVC = UIActivityViewController(activityItems: dataArr, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(_, complete, _, error) -> Void in
            if complete {
                Complete(error)
            }
        }

        self.present(activityVC, animated: true, completion: nil)
    }

    func alertSpaceWarn() {
        let alert = UIAlertController(title: "Warn", message: "Disk space not enough", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "I Know", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    func alert(title: String,
               placeholder: String,
               filedText: String? = nil,
               defaultTitle:String,
               defaultAction: @escaping ((String)->Void)) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        var tmpTextFiled: UITextField?
        alert.addTextField {[weak self] textFiled in
            guard let self = self else {
                return
            }
            tmpTextFiled = textFiled
            textFiled.text = filedText
            textFiled.placeholder = placeholder
            textFiled.addTarget(self, action: #selector(self.textFiledDidChange(_:)), for: .editingChanged)
        }
        let cancel = UIAlertAction(title: "cancel", style: .default)
        alert.addAction(cancel)
        let defaultA = UIAlertAction(title: defaultTitle, style: .default, handler: { (_) in
            defaultAction((tmpTextFiled?.text)!)
        })
        defaultA.isEnabled = false
        defaultA.setValue(UIColor.gray, forKey: "titleTextColor")
        alert.addAction(defaultA)
        self.present(alert, animated: true, completion: nil)
        self.alert = alert
    }
    
    @objc func textFiledDidChange(_ textFiled: UITextField) {
        guard let text = textFiled.text,
              let alert = self.alert else {
            return
        }
        if text.count > 16 {
            textFiled.text = textFiled.text?.subString(to: 16)
            CDHUDManager.shared.showText("The maximum length of name is 16 characters")
        }
        alert.actions.last?.isEnabled = !text.isEmpty
        if text.isEmpty {
            alert.actions.last?.setValue(UIColor.gray, forKey: "titleTextColor")
        } else {
            alert.actions.last?.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        }
    }
    
    func addFollder(folderType: NSFolderType, doneAction: @escaping((CDSafeFolder)->Void)) {
        let title = folderType == .Media ? "Create an Album" : "Create an Folder"
        let placeholder = folderType == .Media ? "Enter a name for a album" : "Enter a name for a folder"

        alert(title: title,placeholder: placeholder, defaultTitle: "Create") { text in

            let time = GetTimestamp()
            let folderInfo = CDSafeFolder()
            folderInfo.folderName = text
            folderInfo.folderType = folderType
            folderInfo.folderStatus = .Custom
            folderInfo.isLock = .LockOn
            folderInfo.userId = FIRSTUSERID
            folderInfo.createTime = Int(time)
            folderInfo.superId = ROOTSUPERID
            var folderPath = ""
            if folderType == .File {
                folderPath = String.CuatomFile().appendingPathComponent(str: "\(text)")
            }else{
                folderPath = String.CuatomMedia().appendingPathComponent(str: "\(text)")
                let thumb = folderPath.appendingPathComponent(str: "thump")
                thumb.create()
            }
            folderPath.create()
            folderInfo.folderPath = folderPath.relativePath
            let folderId = CDSqlManager.shared.addSafeFoldeInfo(folder: folderInfo)
            folderInfo.folderId = folderId
            doneAction(folderInfo)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var guaideView: CDGuidedPaymentView = {
        let guaideView = CDGuidedPaymentView(frame: CGRect(x: 0, y: 0, width: CDSCREEN_WIDTH, height: CDSCREEN_HEIGTH))
        UIDevice.keyWindow().addSubview(guaideView)
        UIDevice.keyWindow().bringSubviewToFront(guaideView)
        return guaideView
    }()
    
    func guidedPayment(complete: @escaping(()->Void)) {
        if CDSignalTon.shared.vipType == .vip {
            complete()
            return
        }
        
        if CDSignalTon.shared.rewardAdsCount >= 5 {
            self.present(self.vipVC, animated: true)
            return
        }
        if let rewardedAd = CDSignalTon.shared.rewardedAd {
            do {
                try rewardedAd.canPresent(fromRootViewController: self)
                
                self.guaideView.showPopView()
                guaideView.actionHandler = {[weak self] in
                    guard let self = self else { return }
                    self.startRewardAdsSdk(rewardedAd: rewardedAd, complete: complete)

                }
            }catch {
                self.vipVC.isShowInterAds = false
                self.present(self.vipVC, animated: true)
            }
        } else {
            self.vipVC.isShowInterAds = false
            self.present(self.vipVC, animated: true)
            CDSignalTon.shared.makeRewardedAd { _ in}
        }
       
    }

    func startBannerAdsSdk() {
        DispatchQueue.main.async {
            guard !self.isMobileAdsStartCalld else { return }
            self.isMobileAdsStartCalld = true
            self.bannerView.load(GADRequest())
        }
    }

    func startRewardAdsSdk(rewardedAd: GADRewardedAd, complete: @escaping(()->Void)) {
        rewardedAd.present(fromRootViewController: self, userDidEarnRewardHandler: {})
        UserDefaults.standard.set(Date(), forKey: "LastRewardAdsDate")
        CDSignalTon.shared.rewardAdsCount += 1
        CDConfigFile.setIntValueToConfigWith(key: .rewardAdCount, intValue: CDSignalTon.shared.rewardAdsCount + 1)
        CDSignalTon.shared.rewardedAd = nil
        CDSignalTon.shared.makeRewardedAd { _ in}

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            complete()
        }
        
    }
    
    func startInterstitialAdsSdk(_ isVipPresent: Bool = false) {
        if CDSignalTon.shared.vipType == .vip {
            return
        }
        
        let lastShowTime = CDConfigFile.getIntValueFromConfigWith(key: .initadsShowTime)
        let current = GetTimestamp() / 1000
        if current - lastShowTime <= 20 {
            return
        }
        
        DispatchQueue.main.async {
            if let rewardedAd = CDSignalTon.shared.interstitiaAd {
                do {
                    try rewardedAd.canPresent(fromRootViewController: self)
                    rewardedAd.present(fromRootViewController: self)
                    let current = GetTimestamp() / 1000
                    CDConfigFile.setIntValueToConfigWith(key: .initadsShowTime, intValue: current)
                    CDSignalTon.shared.makeInterstitialAd { ad in}
                }catch {
                    CDPrintManager.log(" Interstitial Ads prenent failed:\(error.localizedDescription)", type: .ErrorLog)
                    
                    CDSignalTon.shared.makeInterstitialAd { ad in}
                }
                
            } else {
                CDSignalTon.shared.makeInterstitialAd { ad in
                    ad?.present(fromRootViewController: self)
                    let current = GetTimestamp() / 1000
                    CDConfigFile.setIntValueToConfigWith(key: .initadsShowTime, intValue: current)
                }
            }
        }
    }
}

extension CDBaseAllViewController: GADBannerViewDelegate,GADFullScreenContentDelegate{
    
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("------------Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad will present full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("-----------Ad will present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("-------------Ad did dismiss full screen content.")
      }
}
