//
//  CDSignalTon.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Foundation
import ZLPhotoBrowser
import Photos
//import FirebaseAnalytics
import StoreKit
//import GoogleMobileAds
class CDSignalTon: NSObject {

    var basePwd = String() //
    var userId: Int = 0
    var customPickerView: UIViewController! // 记录present的页面，程序进入后台时dismiss掉
    var tab: CDTabBarViewController?
    var navigationBar: CDNavigationController!
    var isFirstInstall = false
    var isCanPutBack = false
    var isCanDelete = false
    var isCanAddWeb = false
    var isInterPop = false
    var rewardAdsCount = 0
//    var rewardedAd: GADRewardedAd?
//    var interstitiaAd: GADInterstitialAd?
    var vipType:NKVipType {
        set{
            CDConfigFile.setIntValueToConfigWith(key: .vipType, intValue: newValue.rawValue)
            
        }
        get{
            let vipNum = CDConfigFile.getIntValueFromConfigWith(key: .vipType)
            return NKVipType(rawValue: vipNum <= 0 ? 0 : vipNum)!
        }
    }
    static let shared = CDSignalTon()
    private override init() {
        super.init()
        userId = FIRSTUSERID
        isFirstInstall = checkFirstInstall()
        if isFirstInstall {// 首次登陆需要创建文件夹等等
//            Analytics.setUserProperty("true", forName: "first_time_user")
//            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
            CDConfigFile.setIntValueToConfigWith(key: .userId, intValue: userId)
            CDConfigFile.setOjectToConfigWith(key: .firstInstall, value: "YES")
            checkNetwork()
        }
        basePwd = CDSqlManager.shared.queryPasscodeWithUserId()
        
        if let lastDate = UserDefaults.standard.object(forKey: "LastRewardAdsDate") as? Date {
            if Calendar.current.isDateInToday(lastDate) {
                rewardAdsCount = CDConfigFile.getIntValueFromConfigWith(key: .rewardAdCount)
            } else {
                rewardAdsCount = 0
                CDConfigFile.setIntValueToConfigWith(key: .rewardAdCount, intValue: 0)

            }
        }
//        makeRewardedAd { _ in}

            
    }

    func saveFileWithUrl(fileUrl: URL, folderInfo: CDSafeFileInfo?) {
        let tmpFilePath = fileUrl.absoluteString
        let fileName = tmpFilePath.fileName
        let suffix = tmpFilePath.suffix
        var contentData = Data()
        // 保存数据到临时data
        do {
            try contentData = Data(contentsOf: fileUrl)
        } catch {
            print("saveFileWithUrl Fail :\(error.localizedDescription)")
            return
        }
        if contentData.count <= 0 {
            print("saveFileWithUrl Fail :Content is nil")
            return
        }
        
        if FileManager.default.fileExists(atPath: tmpFilePath) {
            try! FileManager.default.removeItem(atPath: tmpFilePath)
        }

        let superId = folderInfo == nil ? ROOTSUPERID : folderInfo!.selfId
        let folderPath = folderInfo == nil ? String.RootPath() : folderInfo!.path.absolutePath
        let currentTime = GetTimestamp()
        let fileInfo = CDSafeFileInfo()
        fileInfo.superId = superId
        fileInfo.userId = FIRSTUSERID
        fileInfo.name = fileName
        fileInfo.type = .file
        var filePath: String!

        do {
            filePath = folderPath.appendingPathComponent(str: "\(currentTime).\(suffix)")
            try contentData.write(to: filePath.pathUrl)
        } catch {
            print("save file error:\(error)")
        }
        if suffix.isImage {
            let thumbPath = folderPath.thumpPath.appendingPathComponent(str: "\(currentTime).\(suffix)")
            let image = UIImage.previewImage(videoUrl: filePath.pathUrl)
            let data = image?.jpegData(compressionQuality: 0.5)
            do {
                try data?.write(to: thumbPath.pathUrl)
            } catch {
                CDPrintManager.log("save Midea error:", type: .ErrorLog)
            }
            fileInfo.thumbPath = thumbPath.relativePath
        }
        
        let fileAttribute = filePath.fileAttribute
        fileInfo.size = fileAttribute.fileSize
        fileInfo.createTime = fileAttribute.createTime
        fileInfo.path = filePath.relativePath
        _ = CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
    }

    func saveMedia(_ models: [ZLResultModel], _ folderInfo: CDSafeFileInfo) {
        DispatchQueue.main.async {
            CDHUDManager.shared.showProgress("Start import")

        }
        var index = 0
        for i in 0..<models.count {
            DispatchQueue.main.async {
                CDHUDManager.shared.updateProgress(num: Float(i)/Float(models.count), text: "\(i)/\(models.count)")
            }
            let model = models[i]
            saveOrigialImage(model.image, folderInfo)
            index += 1
            if index == models.count {
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideProgress()
                    NotificationCenter.default.post(name: NSNotification.Name("addMediaSuccess"), object: nil)
                }
            }
        }
    }
    
//    func moveFileToOtherFolder(file: CDSafeFileInfo, moveFolder: CDSafeFileInfo) {
//        let defaultPath = file.path.absolutePath
//        let moveFilePath = moveFolder.folderPath.absolutePath.appendingPathComponent(str: file.filePath.lastPathComponent)
//        let tmp = file
//        tmp.filePath = moveFilePath.relativePath
//        tmp.folderType = moveFolder.folderType
//        tmp.folderId = moveFolder.folderId
//        do {
//            try FileManager.default.moveItem(atPath: defaultPath, toPath: moveFilePath)
//        } catch {
//            print("move file error:\(error)")
//
//        }
//        if file.folderType == .Media {
//            let thumbPath = file.thumbImagePath.absolutePath
//            let moveThumbPath = moveFolder.folderPath.absolutePath.thumpPath.appendingPathComponent(str: "\(file.fileName).png")
//            do {
//                try FileManager.default.moveItem(atPath: thumbPath, toPath: moveThumbPath)
//            } catch {
//                print("move thumb file error:\(error)")
//            }
//
//            tmp.thumbPath = moveThumbPath.relativePath
//
//        }
//        CDSqlManager.shared.updateOneSafeFileInfo(fileInfo: tmp)
//        NotificationCenter.default.post(name: NSNotification.Name("addMediaSuccess"), object: nil)
//
//
//    }
    /**
     保存原始图片
     */
    func saveOrigialImage(_ image: UIImage, _ folderInfo: CDSafeFileInfo) {
        let creatime = GetTimestamp()
        let fileName = "\(creatime)"
        let savePath = folderInfo.path.absolutePath.appendingPathComponent(str: "\(fileName).png")
        let thumbPath = folderInfo.path.absolutePath.thumpPath.appendingPathComponent(str: "\(fileName).png")
        let thumbImage = image.scaleAndCropToMaxSize(newSize: CGSize(width: 200, height: 200))
        let imageData = image.pngData()
        let thumbImageData = thumbImage.pngData()
        do {
            try imageData!.write(to: savePath.pathUrl)
            try thumbImageData!.write(to: thumbPath.pathUrl)

        } catch {
            assertionFailure("save original image fail:\(error.localizedDescription)")
        }
        
        let fileInfo: CDSafeFileInfo = CDSafeFileInfo()
        fileInfo.superId = folderInfo.selfId
        fileInfo.name = fileName.removeSuffix()
        fileInfo.path = savePath.relativePath
        fileInfo.thumbPath = thumbPath.relativePath
        let fileAttribute = savePath.fileAttribute
        fileInfo.size = fileAttribute.fileSize
        fileInfo.createTime = creatime
        fileInfo.type = .file
        fileInfo.userId = FIRSTUSERID
        _ = CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
    }

    func savePlainText(fileName: String?, content: String?, folder: CDSafeFileInfo) -> CDSafeFileInfo{
        let fileName = fileName ?? "Untitled"
        let createTime = GetTimestamp()
        
        let fileInfo = CDSafeFileInfo()
        fileInfo.superId = folder.selfId
        fileInfo.name = fileName
        fileInfo.type = .file
        fileInfo.userId = FIRSTUSERID
        fileInfo.createTime = createTime
        let filePath = folder.path.absolutePath.appendingPathComponent(str: "\(createTime).txt")
        let content = content ?? ""
        let data = content.data(using: .utf8)
        
        do {
            try data?.write(to: filePath.pathUrl)
        } catch {
            assertionFailure("New note save txt failed:\(error.localizedDescription)")
        }
        
        fileInfo.path = filePath.relativePath
        let fileId = CDSqlManager.shared.addSafeFileInfo(fileInfo: fileInfo)
        fileInfo.selfId = fileId
        return fileInfo
    }
    
    func deleteSystemPhoto(_ results: [ZLResultModel]) {
        
        CDHUDManager.shared.showWait()
        DispatchQueue.global().async {
            let tmp = results.map { model in
                return model.asset
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(tmp as NSFastEnumeration)
            } completionHandler: { success, error in
                
                DispatchQueue.main.async {
                    CDHUDManager.shared.hideWait()
                    if success {
                        CDHUDManager.shared.showComplete("Done!")
                    }
                }
            }
        }
    }
    
    func rataApp(isGoStore: Bool) {
        if isGoStore {
            if let url = URL(string: "https://apps.apple.com/app/id6476800308"),
               UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            guard let scene = UIDevice.keyWindow().windowScene else {
                return
            }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
//    func makeRewardedAd(complete: @escaping((GADRewardedAd?) ->Void)) {
//        if vipType == .vip {
//            return
//        }
//        rewardedAd = nil
//        let request = GADRequest()
////#if DEBUG
////        let id = "ca-app-pub-3940256099942544/1712485313"
////#else
//        let id = "ca-app-pub-6968510103744100/3946571521"
////#endif
//        GADRewardedAd.load(withAdUnitID: id,
////                           request: request,
//                           completionHandler: { [self] ad, error in
//            if let error = error {
//                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
//                complete(nil)
//
//                return
//            }
//            rewardedAd = ad
//            complete(ad!)
//        })
//    }
//
//    func makeInterstitialAd(complete:@escaping ((GADInterstitialAd?) ->Void)) {
//        if vipType == .vip {
//            return
//        }
//        interstitiaAd = nil
//        let request = GADRequest()
//
//#if DEBUG
//        let id = "ca-app-pub-3940256099942544/4411468910"
//#else
//        let id = "ca-app-pub-6968510103744100/3056215587"
//#endif
//        GADInterstitialAd.load(withAdUnitID: id, request: request) { [self] ad, error in
//            if let error = error {
//                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
//                complete(nil)
//                return
//            }
//            print("create new interstitiaAd")
//
//            interstitiaAd = ad
//            complete(ad!)
//        }
//    }

    
}
