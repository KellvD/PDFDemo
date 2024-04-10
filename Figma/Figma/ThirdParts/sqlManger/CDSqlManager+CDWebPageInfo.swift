//
//  CDSqlManager+CDWebPageInfo.swift
//  Figma
//
//  Created by dong chang on 2024/1/21.
//

import UIKit
import SQLite

extension CDSqlManager {
    internal func  createWebPageInfoTab() {
        do {
            let create1 = WebPageInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_thumbImagePath)
                build.column(db_webId)
                build.column(db_userId)
                build.column(db_webType)
                build.column(db_webName)
                build.column(db_webUrl)
                build.column(db_createTime)
                build.column(db_iconImagePath)
            }
            try db.run(create1)
        } catch {
            assertionFailure("error:\(error)")
        }
    }

    // MARK: SafeFile
    private func getWebPageInfoFromItem(item: Row) -> CDWebPageInfo {
        let file = CDWebPageInfo()
        file.webId = item[db_webId]
        file.createTime = item[db_createTime]
        file.webName = item[db_webName]
        file.webType = CDWebPageInfo.NSWebType(rawValue: item[db_webType])
        file.thumbImagePath = item[db_thumbImagePath]
        file.userId = item[db_userId]
        file.isSelected = .no
        file.webUrl = item[db_webUrl]
        file.iconImagePath = item[db_iconImagePath]
        return file
    }
    
 
     
    public func addWebPageInfo(fileInfo: CDWebPageInfo) -> Int{
        
        let fileId = queryMaxWebId() + 1
        do {
            try db.run(WebPageInfo.insert(
                db_thumbImagePath <- fileInfo.thumbImagePath,
                db_webId <- fileId,
                db_webName <- fileInfo.webName,
                db_webType <- fileInfo.webType.rawValue,
                db_webUrl <- fileInfo.webUrl,
                db_userId <- FIRSTUSERID,
                db_createTime <- fileInfo.createTime,
                db_iconImagePath <- fileInfo.iconImagePath)
            )
            
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileId
    }
    
    public func queryMaxWebId() -> Int {

        var maxFileId = 0
        do {
            let sql = WebPageInfo.filter(db_userId == FIRSTUSERID)
            maxFileId = try db.scalar(sql.select(db_webId.max)) ?? 0
        } catch {
            assertionFailure("error:\(error)")
        }
        return maxFileId
    }
    
    public func queryCustomWebPageCount() -> Int {

        var totalCount = 0
        do {
            let sql = WebPageInfo.filter(db_webType == CDWebPageInfo.NSWebType.normal.rawValue)
            totalCount = try db.scalar(sql.count)
        } catch {
            assertionFailure("error:\(error)")
            
        }
        return totalCount
    }
    

    public func queryWebPageCount(_ type: CDWebPageInfo.NSWebType = .normal) -> Int {

        var totalCount = 0
        do {
            let sql = WebPageInfo.filter(db_webType == type.rawValue)
            totalCount = try db.scalar(sql.count)
        } catch {
            CDPrintManager.log("queryOneFolderFileCount-->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }
    
    
    public func queryAllWebPage(type: CDWebPageInfo.NSWebType)-> [CDWebPageInfo] {
        var fileArr: [CDWebPageInfo] = []
        do {
            let sql = WebPageInfo.filter(db_webType == type.rawValue).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getWebPageInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileArr
    }
    
    public func deleteOneWebage(webId: Int) {
        do {
            try db.run(WebPageInfo.filter(db_webId == webId).delete())
        } catch {
            assertionFailure("error:\(error)")
        }
    }
    
    func updateOneWebage(fileInfo: CDWebPageInfo) {
        if fileInfo.thumbImagePath.hasPrefix(String.RootPath()) {
            fileInfo.thumbImagePath = fileInfo.thumbImagePath.relativePath
        }
        do {
            let sql = WebPageInfo.filter(db_webId == fileInfo.webId)

            try db.run(sql.update(
                db_thumbImagePath <- fileInfo.thumbImagePath,
                db_webId <- fileInfo.webId,
                db_webName <- fileInfo.webName,
                db_webType <- fileInfo.webType.rawValue,
                db_webUrl <- fileInfo.webUrl,
                db_userId <- FIRSTUSERID,
                db_createTime <- fileInfo.createTime,
                db_iconImagePath <- fileInfo.thumbImagePath)
            )
        } catch {
            assertionFailure("error:\(error)")
        }
    }
    
    public func updateWebPageIcon(iconUrl: String, webId: Int) {
        do {
            let sql = WebPageInfo.filter(db_webId == webId)
            try db.run(sql.update(db_iconImagePath <- iconUrl))
        } catch {
            assertionFailure("error:\(error)")
        }

    }
    
    public func updateWebPageThumb(thumbPath: String, webId: Int) {
        var thum = thumbPath
        if thumbPath.hasPrefix(String.RootPath()) {
            thum = thumbPath.relativePath
        }
        do {
            let sql = WebPageInfo.filter(db_webId == webId)
            try db.run(sql.update(db_thumbImagePath <- thum))
        } catch {
            assertionFailure("error:\(error)")
        }

    }
    
    public func updateWebPagewWebType(type: CDWebPageInfo.NSWebType, webId: Int) {
        do {
            let sql = WebPageInfo.filter(db_webId == webId)
            try db.run(sql.update(db_webType <- type.rawValue))
        } catch {
            assertionFailure("error:\(error)")
        }

    }
}
