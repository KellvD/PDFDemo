//
//  CDSQLModel.swift
//  MyBox
//
//  Created by changdong on 2020/5/1.
//  Copyright © 2019 baize. All rights reserved.
//

import UIKit

class CDUserInfo: NSObject {

    var userId = Int()
    var basePwd = String()
}

class CDSafeFolder: NSObject {
    enum CDSelectedStatus: Int {
        case yes // 选中
        case no  // 未选中
    }

    var folderName = String()  // 文件夹名称
    var userId = Int()
    var superId = Int()
    var folderId = Int()       // 文件夹id
    var folderType: NSFolderType! // 文件夹类型
    var folderStatus: NSFolderStatus! // 文件夹类型
    var isLock:NSFolderLock!          // 文件夹是否新建还是默认
    var createTime = Int()       // 文件夹创建时间
    var folderPath = String()    // 文件夹路径
    var isSelected: CDSelectedStatus! // 不入库，作为判断文件操作时是否选中，出库时设置为”false“,选中时设置为”True“，最后判断本字段
    var count = Int()
    var lifeCircle: NSLifeCircle = .normal
}

class CDSafeFileInfo: NSObject {
    enum CDSelectedStatus: Int {
        case yes // 选中
        case no  // 未选中
    }
    enum NSFileGrade: Int {
        case lovely   // 喜爱收藏
        case normal   // 普通
    }

    enum NSFileType: Int {
        case PlainTextType = 0
        case ImageType = 1
        case VideoType = 2
    }

    var fileId = Int()
    var folderId = Int()
    var fileSize = Int()
    var fileWidth = Double()
    var fileHeight = Double()
    var timeLength = Double()
    var createTime = Int() // 创建时间 相册，沙盒导入文件的创建时间
    var fileType: NSFileType!
    var fileName = String()
    var thumbImagePath = String()
    var filePath = String()
    var userId = Int()
    var grade: NSFileGrade = .normal
    var isSelected: CDSelectedStatus = .no
    var folderType: NSFolderType! // 文件所属大类
    var lifeCircle: NSLifeCircle = .normal

}


class CDWebPageInfo: NSObject {
    enum CDSelectedStatus: Int {
        case yes // 选中
        case no  // 未选中
    }
    
    enum NSWebType: Int {
        case history = 0
        case normal = 1
        case lock = 2
    }

    var webId = Int()
    var createTime = Int() // 创建时间 相册，沙盒导入文件的创建时间
    var webType: NSWebType!
    var webName = String()
    var thumbImagePath = String()
    var iconImagePath = String()
    var webUrl = String()
    var userId = Int()
    var isSelected: CDSelectedStatus!
}


class CDAppBuyInfo : NSObject{
    var productId:Int = 0              //购买产品的唯一标识 自增变量
    var buyTime:Int = 0                      //购买时间
    var productIdentifier:String = ""          //产品标识
    var receipt:String = ""                   //支付单号
    var price:String = ""                     //价格
    var productName:String = ""               //产品名字
    var order:Int = 0 //排序，服务器返回顺序不一样
}
