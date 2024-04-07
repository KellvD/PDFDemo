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

class CDSafeFileInfo: NSObject {
    enum InfoType: Int {
        case folder
        case file
    }
    
    enum NSFileType: Int {
        case pdf = 0
        case image = 1
    }
    var selfId = Int()
    var superId = Int()
    var size = Int()
    var createTime = Int()
    var type: InfoType!
    var name = String()
    var thumbPath = String()
    var path = String()
    var userId = Int()
    var lock = Int()
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


enum CDToolOption: String {
case document = "Document"
case idScanner = "ID Scanner"
case ocr = "OCR"
case qrCode = "QR Code"
case pdfToDocx = "PDF To Docx"
case pdfToTab = "PDF To Tables"
case pdfToImage = "PDF To Image"
case docxToPdf = "Docx To PDF"
case tabToPdf = "Tables To PDF"
case imageToPdf = "Image To PDF"
case signature = "Signature"
case textEditor = "Text Editor"
case watermark = "Watermark"
case pdfEnc = "PDF Encryption"
}
