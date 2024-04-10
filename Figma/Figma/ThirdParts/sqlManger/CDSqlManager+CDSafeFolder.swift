//
//  CDSqlModel+CDSafeFolder.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
// MARK: 文件夹
extension CDSqlManager {
    internal func createSafeFoldeTab() {
        do {
            let create = SafeFolder.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_folderName)
                build.column(db_folderId)
                build.column(db_folderType)
                build.column(db_folderStatus)
                build.column(db_isLock)
                build.column(db_createTime)
                build.column(db_userId)
                build.column(db_folderPath)
                build.column(db_superId)
            }

            try db.run(create)
            CDPrint(item: "createSafeFolder -->success")

        } catch {
            CDPrintManager.log("createSafeFolder -->error:\(error)", type: .ErrorLog)
        }
    }

    private func getSafeFolderFromItem(item: Row) -> CDSafeFolder {
        let folderInfo = CDSafeFolder()
        folderInfo.folderName = item[db_folderName]
        folderInfo.folderId = item[db_folderId]
        folderInfo.folderType = NSFolderType(rawValue: item[db_folderType])
        folderInfo.folderStatus = NSFolderStatus(rawValue: item[db_folderStatus])
        folderInfo.isLock = NSFolderLock(rawValue: item[db_isLock])
        folderInfo.createTime = item[db_createTime]
        folderInfo.userId = item[db_userId]
        folderInfo.superId = item[db_superId]
        folderInfo.folderPath = item[db_folderPath]
        folderInfo.isSelected = .no
        folderInfo.count = queryOneFolderFileCount(with: folderInfo)

        folderInfo.lifeCircle = NSLifeCircle(rawValue: item[db_lifeCircle])!

        return folderInfo
    }

    @discardableResult
    public func addSafeFoldeInfo(folder: CDSafeFolder) -> Int {

        let folderId = queryMaxSafeFolderId()+1
    
        do {
            try db.run(SafeFolder.insert(
                db_folderName <- folder.folderName,
                db_folderId <- folderId,
                db_folderType <- folder.folderType!.rawValue,
                db_folderStatus <- folder.folderStatus!.rawValue,
                db_isLock <- folder.isLock.rawValue,
                db_createTime <- folder.createTime,
                db_folderPath <- folder.folderPath,
                db_userId <- FIRSTUSERID,
                db_superId <- ROOTSUPERID,
                db_lifeCircle <- NSLifeCircle.normal.rawValue
            ))

            CDPrint(item: "addSafeFoldeInfo-->success")

        } catch {
            CDPrintManager.log("addSafeFoldeInfo-->error:\(error)", type: .ErrorLog)
        }
        return folderId
    }
    
    public func queryDefaultAllMediaFolder() -> [CDSafeFolder] {
        var totalArr: [CDSafeFolder] = []
        var delet:CDSafeFolder?
        do {
            let sql = SafeFolder.where(db_folderType == NSFolderType.Media.rawValue && db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_folderId.asc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                if folderInfo.folderStatus == .Delete {
                    delet = folderInfo
                    continue
                }
                totalArr.append(folderInfo)
            }
            if let tmpd = delet {
                totalArr.append(tmpd)
            }
            
        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    public func queryDefaultAllMediaExitFolder(folderId: Int?) -> [CDSafeFolder] {
        var totalArr: [CDSafeFolder] = []
        var delet:CDSafeFolder?
        let folId = folderId == nil ? -1: folderId!
        do {
            
           
            let sql = SafeFolder.where(db_folderId != folId &&
                                       db_folderType == NSFolderType.Media.rawValue &&
                                       (db_folderStatus == NSFolderStatus.Custom.rawValue ||
                                       db_folderStatus == NSFolderStatus.All.rawValue) &&
                                       db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_folderId.asc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                if folderInfo.folderStatus == .Delete {
                    delet = folderInfo
                    continue
                }
                totalArr.append(folderInfo)
            }
            if let tmpd = delet {
                totalArr.append(tmpd)
            }
        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    
    public func queryDefaultAllFileFolder() -> [[CDSafeFolder]] {
        var normal: [CDSafeFolder] = []
        var delete: [CDSafeFolder] = []

        var totalArr: [[CDSafeFolder]] = []
        do {
            let sql = SafeFolder.where(db_folderType == NSFolderType.File.rawValue && db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_folderId.asc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                if folderInfo.folderStatus == .Delete {
                    delete.append(folderInfo)
                } else {
                    normal.append(folderInfo)
                }
            }
            totalArr.append(normal)
            totalArr.append(delete)

        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    public func queryDefaultAllFileExitFolder(folderId: Int) -> [[CDSafeFolder]] {
        var normal: [CDSafeFolder] = []
        var delete: [CDSafeFolder] = []

        var totalArr: [[CDSafeFolder]] = []
        do {
            let sql = SafeFolder.where(db_folderId != folderId &&
                                       db_folderType == NSFolderType.File.rawValue &&
                                       (db_folderStatus == NSFolderStatus.Custom.rawValue ||
                                       db_folderStatus == NSFolderStatus.All.rawValue) &&
                                       db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_folderId.asc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                if folderInfo.folderStatus == .Delete {
                    delete.append(folderInfo)
                } else {
                    normal.append(folderInfo)
                }
            }
            totalArr.append(normal)
            totalArr.append(delete)

        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    
    public func queryDefaultAllFolder() -> [CDSafeFolder] {
        var totalArr: [CDSafeFolder] = []
        do {
            let sql = SafeFolder.where(db_userId == FIRSTUSERID).order(db_folderId.desc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                totalArr.append(folderInfo)
            }
        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    public func queryAllDeleteFolder(folderType: NSFolderType) -> [CDSafeFolder] {
        var totalArr: [CDSafeFolder] = []
        do {
            let sql = SafeFolder.where(db_userId == FIRSTUSERID &&
                                       db_folderType == folderType.rawValue &&
                                       db_lifeCircle == NSLifeCircle.delete.rawValue).order(db_folderId.desc)
            for item in (try db.prepare(sql)) {
                let folderInfo = getSafeFolderFromItem(item: item)
                totalArr.append(folderInfo)
            }
        } catch {
            CDPrintManager.log("queryDefaultAllFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalArr

    }
    
    
    public func queryOneFolderFileCount(with folder: CDSafeFolder) -> Int {
        var totalCount = 0
        do {
            if folder.folderStatus == .Custom || folder.folderStatus == .All {
                let sql = SafeFileInfo.filter(db_folderId == folder.folderId &&
                                              db_lifeCircle == NSLifeCircle.normal.rawValue)
                totalCount = try db.scalar(sql.count)

            } else if folder.folderStatus == .Delete {
                let sql = SafeFileInfo.filter(db_folderType == NSFolderType.Media.rawValue &&
                                              db_lifeCircle != NSLifeCircle.normal.rawValue)
                totalCount = try db.scalar(sql.count)

            } else {
                let sql = SafeFileInfo.filter(db_grade == CDSafeFileInfo.NSFileGrade.lovely.rawValue &&
                                              db_lifeCircle == NSLifeCircle.normal.rawValue)
                totalCount = try db.scalar(sql.count)

            }
            
        } catch {
            CDPrintManager.log("queryOneSafeFileGrade -->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }
    
    
    public func queryOneSafeFolderWith(folderId: Int) -> CDSafeFolder {
        var folderInfo: CDSafeFolder!

        for item in try! db.prepare(SafeFolder.filter(db_folderId == folderId)) {
            folderInfo = getSafeFolderFromItem(item: item)
        }
        return folderInfo
    }
    
    public func queryOneDeleteFolder(type: NSFolderType) -> CDSafeFolder {
        var folderInfo: CDSafeFolder!

        for item in try! db.prepare(SafeFolder.filter(db_folderType == type.rawValue && db_folderStatus == NSFolderStatus.Delete.rawValue)) {
            folderInfo = getSafeFolderFromItem(item: item)
        }
        return folderInfo
    }


    public func queryOneFolderSize(folderId: Int) -> Int {

        var totalSize = 0
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            totalSize = try db.scalar(sql.select(db_fileSize.sum)) ?? 0
        } catch {
            CDPrintManager.log("queryOneFolderSizeByFolder-->error:\(error)", type: .ErrorLog)
        }
        return totalSize
    }

    public func queryOneFolderLifeCircle(folderId: Int) -> NSLifeCircle {
        
        var life:NSLifeCircle = .normal
        do {
            let sql = SafeFolder.filter(db_folderId == folderId)
            for item in try db.prepare(sql.select(db_lifeCircle)) {
                life = NSLifeCircle(rawValue: item[db_lifeCircle])!

            }
        } catch {
            CDPrintManager.log("queryOneFolderSizeByFolder-->error:\(error)", type: .ErrorLog)
        }
        return life
    }
    
    public func queryOneFolderFileCount(folderId: Int) -> Int {

        var totalCount = 0
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            totalCount = try db.scalar(sql.count)
        } catch {
            CDPrintManager.log("queryOneFolderFileCount-->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }
    
    public func queryCustomFoldersCount(folderType: NSFolderType) -> Int {

        var totalCount = 0
        do {
            let sql = SafeFolder.filter(db_folderStatus == NSFolderStatus.Custom.rawValue &&
                                          db_folderType == folderType.rawValue &&
                                          db_lifeCircle == NSLifeCircle.normal.rawValue)
            totalCount = try db.scalar(sql.count)
        } catch {
            assertionFailure("error:\(error)")
            
        }
        return totalCount
    }
    

    public func queryOneFolderSubFolderCount(folderId: Int) -> Int {
        var totalCount = 0
        do {
            let sql = SafeFolder.filter(db_superId == folderId)
            totalCount = try db.scalar(sql.count)
        } catch {
            CDPrintManager.log("queryOneFolderSubFolderCount-->error:\(error)", type: .ErrorLog)
        }
        return totalCount
    }

    public func queryMaxSafeFolderId() -> Int {

        var maxFolderId = 0
        do {
            let sql = SafeFolder.filter(db_userId == FIRSTUSERID)
            maxFolderId = try db.scalar(sql.select(db_folderId.max)) ?? 0
        } catch {
            CDPrintManager.log("querySafeFolderCount-->error:\(error)", type: .ErrorLog)
        }
        return maxFolderId
    }

    /*
     更新文件夹名称（更新修改时间）
     */
    public func updateOneSafeFolder(with folderName: String, folderId: Int) {
        do {
            let sql = SafeFolder.filter(db_folderId == folderId)

            try db.run(sql.update(db_folderName <- folderName))
            CDPrint(item: "updateOneSafeFolderName-->success")

        } catch {
            CDPrintManager.log("updateOneSafeFolderName-->error:\(error)", type: .ErrorLog)
        }
    }
    
    public func updateOneSafeFolder(with lifeCircle: NSLifeCircle, folderId: Int) {
        do {
            let sql = SafeFolder.filter(db_folderId == folderId)

            try db.run(sql.update(db_lifeCircle <- lifeCircle.rawValue))

        } catch {
            assertionFailure("error:\(error)")
        }
    }

    public func deleteOneFolder(folderId: Int) {
        do {
            try db.run(SafeFolder.filter(db_folderId == folderId).delete())
            CDPrint(item: "deleteOneFolder-->success")
        } catch {
            CDPrintManager.log("deleteOneFolder-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteAllSubSafeFolder(superId: Int) {
        do {
            try db.run(SafeFolder.filter(db_superId >= superId).delete())
            CDPrint(item: "deleteAllSubSafeFolder-->success")
        } catch {
            CDPrintManager.log("deleteAllSubSafeFolder-->error:\(error)", type: .ErrorLog)
        }
    }
}
