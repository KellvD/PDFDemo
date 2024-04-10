//
//  CDCustomDefines.swift
//  MyRule
//
//  Created by changdong on 2018/11/12.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import Foundation

let CDSCREEN_WIDTH = UIScreen.main.bounds.size.width
let CDSCREEN_HEIGTH = UIScreen.main.bounds.size.height
let StatusHeight = UIDevice.statusBarHeight()
let NavigationHeight: CGFloat = UIDevice.navigationBarHeight()
let CDViewHeight = CDSCREEN_HEIGTH - NavigationHeight - StatusHeight
// 底部自定义工具栏高度
let BottomBarHeight: CGFloat = UIDevice.tabBarFullHeight()
let thumpImageWidth = (CDSCREEN_WIDTH-6.0)/4.0
let thumpImageHeight = (CDSCREEN_WIDTH-6.0)/4.0

let FIRSTUSERID = 100001 // 数据库ID，扩展多账户模式
let ROOTSUPERID = -1

let SECTION_SPACE: CGFloat = 15.0
let CELL_HEIGHT: CGFloat = 48.0

enum NSFolderType: Int {
    case Media = 0
    case File = 1
}

enum NSFolderStatus: Int {
    case All = 0
    case Favourite = 1
    case Delete = 2
    case Custom = 3
}

enum NSFolderLock: Int {
    case LockOn = 1
    case LockOff = 2
}

enum NKVipType:Int{
    case not = 0
    case vip = 1
}

enum NSLifeCircle: Int {
    case normal = 0
    case delete = 1
    case deleteHasRead
}

enum SDImageFormat: NSInteger {
    case Undefined = -1
    case JPEG = 0
    case PNG = 1
    case GIF
    case TIFF
    case WebP
    case HEIC
}

let IOSVersion = Float(UIDevice.current.systemVersion)

enum CDDevicePermissionType: Int {
    case library = 1 // 图库
    case camera = 2
    case micorphone = 3
    case location = 4
    case faceId

}

enum CDVipType: Int {
    case week = 1
    case year = 2
    case mouth = 3
}

let IAPPubKey = "c8074410a358438e97e68e84c2abc280"
let IAP_Week = "com.wenying.securephoto.week"
let IAP_Year = "com.wenying.securephoto.year"
let IAP_Mouth = "com.wenying.securephoto.month"
