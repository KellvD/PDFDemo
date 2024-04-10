//
//  String+Path.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import AVFoundation

extension String {
    /**
     获取document路径
     */
    static func documentPath() -> String {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return docPath
    }

    /**
    判断路径是否存在，不存在创建
    */
    static func ensurePathAt(path: String) {
        let manager = FileManager.default
        if !manager.fileExists(atPath: path) {
            do {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建路径失败")
            }
        }
    }

    /**
    创建SafeRule路径
    */
    static func RootPath() -> String {
        let docpath = documentPath()
        let userPath = (docpath as NSString).appendingPathComponent("SafeRule")
        ensurePathAt(path: userPath)
        return userPath
    }

    /**
    删除SafeRulek路径
    */
    static func deleteRootPath() {
        let docpath = documentPath()
        let userPath = (docpath as NSString).appendingPathComponent("SafeRule")
        if FileManager.default.fileExists(atPath: userPath) {
            do {
                try FileManager.default.removeItem(atPath: userPath)
            } catch {
            }
        }
    }

    // MARK: 图片路径
    @discardableResult
    static func Media() -> String {
        let path = (RootPath() as NSString).appendingPathComponent("Media")
        ensurePathAt(path: path)
        return path
    }
    
    static func File() -> String {
        let path = (RootPath() as NSString).appendingPathComponent("File")
        ensurePathAt(path: path)
        return path
    }
    
    static func AllMedia() -> String {
        let path = (Media() as NSString).appendingPathComponent("All Media")
        ensurePathAt(path: path)

        let thumbPath = path.appendingPathComponent(str: "thump")
        ensurePathAt(path: thumbPath)
        return path
    }
    
    @discardableResult
    static func Favourite() -> String {
        let path = (Media() as NSString).appendingPathComponent("Favourite")
        ensurePathAt(path: path)
        
        let thumbPath = path.appendingPathComponent(str: "thump")
        ensurePathAt(path: thumbPath)
        return path
    }
    
    @discardableResult
    static func DeleteMedia() -> String {
        let path = (Media() as NSString).appendingPathComponent("Recently Delete")
        ensurePathAt(path: path)
        
        let thumbPath = path.appendingPathComponent(str: "thump")
        ensurePathAt(path: thumbPath)
        return path
    }
    
    static func CuatomMedia() -> String {
        let path = (Media() as NSString).appendingPathComponent("Cuatom Media")
        ensurePathAt(path: path)
        
        let thumbPath = path.appendingPathComponent(str: "thump")
        ensurePathAt(path: thumbPath)
        return path
    }
    
    @discardableResult
    static func WebThumpFile() -> String {
        let path = (File() as NSString).appendingPathComponent("web thump")
        ensurePathAt(path: path)
        return path
    }
    
    static func AllFile() -> String {
        let path = (File() as NSString).appendingPathComponent("All File")
        ensurePathAt(path: path)
        return path
    }
    
    static func CuatomFile() -> String {
        let path = (File() as NSString).appendingPathComponent("Cuatom File")
        ensurePathAt(path: path)
        return path
    }
    
    
    static func DeleteFile() -> String {
        let path = (File() as NSString).appendingPathComponent("Recently Delete")
        ensurePathAt(path: path)
        return path
    }
    
    
    func appendingFormat(_ format: NSString, _ args: CVarArg...) -> NSString {
        let appen = self.AsNSString().appendingFormat(format, args)
        return appen
    }

    func appendingPathComponent(str: String) -> String {
        let appen = self.AsNSString().appendingPathComponent(str)
        return appen
    }

    func AsNSString() -> NSString {
        return (self as NSString)
    }

    func create() {
        String.ensurePathAt(path: self)
    }
    /**
    移除后缀名
    */
    func removeSuffix() -> String {
        let string = self.AsNSString().deletingPathExtension
        return string
    }

    /**
    删除文件
    */
    func delete() {
        let manager = FileManager.default
        if manager.fileExists(atPath: self) {
            do {
                if self.hasPrefix(String.RootPath()) {
                    try manager.removeItem(atPath: self)
                } else {
                    let path = String.RootPath().appendingPathComponent(str: self)
                    try manager.removeItem(atPath: path)
                }

            } catch {
                CDPrintManager.log("文件删除失败", type: .WarnLog)
            }
        }
    }

    // 相对路径
    var relativePath: String {
        get {
            let array: [String] = self.components(separatedBy: String.RootPath())
            let tempString: String = array.last!
            return tempString
        }
    }

    var absolutePath: String {
        get {
            let tempString = String.RootPath().appendingPathComponent(str: self)
            return tempString
        }
    }
    
    var thumpPath: String {
        get {
            let tempString = self.appendingPathComponent(str: "thump")
            return tempString
        }
    }
    
    /**
     获取完整的文件名
     */
    var lastPathComponent: String {
        get {
            let last = self.AsNSString().lastPathComponent
            return last
        }
    }

    /**
    获取不带后缀的文件名
    */
    var fileName: String {
        get {
            let fileLastPath = self.lastPathComponent
            let fileName = fileLastPath.removeSuffix().removePercentEncoding
            return fileName
        }
    }

    /**
    拼接文件完整路径
    */
    var rootPath: String {
        get {
            if !self.hasPrefix(String.RootPath()) {
                return String.RootPath().appendingPathComponent(str: self)
            }
            return self
        }
    }

    /**
    路径转URL
    */
    var pathUrl: URL {
        get {
            return URL(fileURLWithPath: self)
        }
    }
    
    var stringUrl: URL? {
        get {
            return URL(string: self)
        }
    }
    /**
     获取文件后缀
    */
    var suffix: String {

        get {
            let string = self.AsNSString().pathExtension
            return string
        }

    }
    /**
     文件信息
    */
    var fileAttribute:(fileSize: Int, createTime: Int) {
        get {
            var fileSize: Int = 0
            var createTime: Int = 0
            if FileManager.default.fileExists(atPath: self) {
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: self)
                    fileSize = attr[FileAttributeKey.size] as! Int
                    let creationDate = attr[FileAttributeKey.creationDate] as!Date
                    createTime = Int(creationDate.timeIntervalSince1970 * 1000)

                } catch {

                }
            }
            return (fileSize, createTime)
        }

    }
    
    var folderSize: Int{
        var isDir: ObjCBool = false
        let manager = FileManager.default
        var fileSize: Int = 0
        if manager.fileExists(atPath: self, isDirectory: &isDir) {
            if isDir.boolValue {
                let fileArr = manager.subpaths(atPath: self)!
                fileArr.forEach { (path) in
                    let allPath = self + "/" + path
                    fileSize = fileSize + allPath.fileAttribute.fileSize
                }
                return fileSize
            }
        }
        return fileAttribute.fileSize
    }

    var removePercentEncoding: String {
        get {
            let string = self.AsNSString().removingPercentEncoding
            return string!
        }
    }
    
    var fileType: CDSafeFileInfo.NSFileType {
        let tmp = self.uppercased()
        if ["PNG", "JPG", "HEIC", "JPEG", "BMP", "TIF", "PCD", "MAC", "PCX", "DXF", "CDR"].contains(tmp) {
            return .ImageType
        } else if ["MOV", "MP4", "AVI", "MPG", "M2V", "VOB", "ASF", "WMF", "RMVB", "RM", "DIVX", "MKV"].contains(tmp) {
            return .VideoType
        } else {
            return .PlainTextType
        }
    }

    
}

