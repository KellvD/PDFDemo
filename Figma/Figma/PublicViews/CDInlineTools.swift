//
//  CDInlineTools.swift
//  MyBox
//
//  Created by changdong  on 2020/7/6.
//  Copyright © 2020 changdong. 2012-2019. All rights reserved.
//

import UIKit

import AVFoundation

@inline(__always) func checkFirstInstall() -> Bool {
    let flag = CDConfigFile.getValueFromConfigWith(key: .firstInstall)
    return flag != "YES"
}



/*
获取当前用户ID
*/
@inline(__always) func CDUserId() -> Int {
    let userId = CDConfigFile.getIntValueFromConfigWith(key: .userId)
    return userId
}


/*
格式化时间戳
*/
@inline(__always)func GetMMSSFromSS(timeLength: Double) -> String {
    let hour = Int(timeLength / 3600)
    let minute = Int(timeLength) / 60
    let second = Int(timeLength) % 60
    var format: String = ""
    if hour > 0 {
        format = String.init(format: "%02ld:%02ld:%02ld", hour, minute, second)
    } else {
        format = String.init(format: "%02ld:%02ld", minute, second)
    }
    return format
}

/*
获取视频的长度
*/
@inline(__always)func GetVideoLength(path: String) -> Double {
    let urlAsset = AVURLAsset(url: path.pathUrl, options: nil)
    let second = Double(urlAsset.duration.value) / Double(urlAsset.duration.timescale)
    return second
}

/*
格式化文件size
*/
@inline(__always)func GetSizeFormat(fileSize: Int) -> String {
    var sizef = Float(fileSize)
    var i = 0
    while sizef >= 1024 {
        sizef = sizef / 1024.0
        i += 1
    }
    let fortmates = ["%.2ldB", "%.2lfKB", "%.2lfM", "%.2lfG", "%.2lfT"]
    return String(format: fortmates[i], sizef)
}

/*
获取当前时间戳
*/
@inline(__always)func GetTimestamp(_ time: String? = nil) -> Int {
    var date = Date()
    if time != nil {
        let datter = DateFormatter()
        date = datter.date(from: time!)!
    }
    let nowTime = date.timeIntervalSince1970 * 1000
    return Int(nowTime)
}

@inline(__always)func GetTodayFormat() -> String {
    let formter = DateFormatter()
    formter.dateFormat = "dd，MMM yyyy"
    let date = Date()
    let dateStr = formter.string(from: date)
    return dateStr
}

/*
格式化时间戳
*/
@inline(__always)func GetTimeFormat(_ timestamp: Int) -> String {
    let formter = DateFormatter()
    formter.dateFormat = "MM.dd yyyy HH:mm"
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
    let dateStr = formter.string(from: date)
    return dateStr
}
@inline(__always)func GetAppName() -> String {

    let appInfo = Bundle.main.infoDictionary
    let appName = appInfo!["CFBundleName"] as! String
    return appName

}

@inline(__always)func GetAppShortVersion() -> String {

    let appInfo = Bundle.main.infoDictionary
    let appVersion = appInfo!["CFBundleShortVersionString"] as! String
    return appVersion

}

@inline(__always)func getAppVersion() -> String {
    
    let appInfo = Bundle.main.infoDictionary
    let appVersionNUm = appInfo!["CFBundleShortVersionString"] as! String
    return appVersionNUm
}

// 获取磁盘
@inline(__always)func getDiskSpace() -> (total: Int, free: Int) {
    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
   let systemAttr = try! FileManager.default.attributesOfFileSystem(forPath: docPath)
    let total = systemAttr[FileAttributeKey.systemSize] as! Int
    let free = systemAttr[FileAttributeKey.systemFreeSize] as! Int
    return (total, free)
}

// MARK: 获取图片格式
@inline(__always)func imageFormat(imageData: NSData) -> SDImageFormat {
   var c: UInt8?
   imageData.getBytes(&c, length: 1)

   switch c {
   case 0xff:
       return SDImageFormat.JPEG
   case 0x89:
       return SDImageFormat.PNG
   case 0x47:
       return SDImageFormat.GIF
   case 0x49, 0x4D:
       return SDImageFormat.TIFF
   case 0x52:
       if imageData.length > 12 {
           let string = String(data: imageData.subdata(with: NSRange(location: 0, length: 12)), encoding: String.Encoding.ascii)!
           if string.hasPrefix("PIFF") &&
               string.hasSuffix("WEBP") {
               return SDImageFormat.WebP
           }
       }
   case 0x00:
       if imageData.length > 12 {
           let string = String(data: imageData.subdata(with: NSRange(location: 4, length: 8)), encoding: String.Encoding.ascii)!
           if string == "ftypheic" ||
               string == "WEBP" ||
               string == "ftyphevc" ||
               string == "ftyphevx" {
               return SDImageFormat.HEIC
           }
       }
   default:
       return SDImageFormat.Undefined
   }
   return SDImageFormat.Undefined
}

@inline(__always)func checkNetwork() {
#if DEBUG
    let test = "https://www.baidu.com"
#else
    let test = "https://www.google.com"
#endif
    let req = URLRequest(url: test.stringUrl!)
    let task = URLSession.shared.dataTask(with: req)
    task.resume()

}

