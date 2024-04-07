//
//  CDSqlModel+CDSafeFileInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
extension CDSqlManager {
    internal func  createSafeFileInfoTab() {
        do {
            let create1 = SafeFileInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_id, primaryKey: true)
                build.column(db_selfId)
                build.column(db_userId)
                build.column(db_size)
                build.column(db_createTime)
                build.column(db_type)
                build.column(db_name)
                build.column(db_thumbPath)
                build.column(db_path)
                build.column(db_superId)
                build.column(db_lock)
            }
            try db.run(create1)
            CDPrint(item: "createSafeFileInfo -->success")
        } catch {
            CDPrintManager.log("createSafeFileInfo-->error:\(error)", type: .ErrorLog)
            assertionFailure()
        }
    }

    // MARK: SafeFile
    private func getSafeFileInfoFromItem(item: Row) -> CDSafeFileInfo {
        let file = CDSafeFileInfo()
        file.selfId = item[db_selfId]
        file.userId = item[db_userId]
        file.size = item[db_size]
        file.createTime = item[db_createTime]
        file.name = item[db_name]
        file.createTime = item[db_createTime]
        file.thumbPath = item[db_thumbPath]
        file.type = CDSafeFileInfo.InfoType(rawValue: item[db_type])
        file.path = item[db_path]
        file.superId = item[db_superId]
        file.lock = item[db_lock]
        return file
    }

    public func addSafeFileInfo(fileInfo: CDSafeFileInfo) -> Int {

        let fileId = queryMaxFileId() + 1
        do {
            try db.run(SafeFileInfo.insert(
                db_selfId <- fileId,
                db_userId <- fileInfo.userId,
                db_size <- fileInfo.size,
                db_createTime <- fileInfo.createTime,
                db_type <- fileInfo.type.rawValue,
                db_name <- fileInfo.name,
                db_thumbPath <- fileInfo.thumbPath,
                        db_createTime <- fileInfo.createTime,
                db_path <- fileInfo.path,
                db_superId <- fileInfo.superId,
                db_lock <- fileInfo.lock)

            )

            CDPrint(item: "addSafeFileInfo-->success")
        } catch {
            CDPrintManager.log("addSafeFileInfo-->error:\(error)", type: .ErrorLog)
        }
        return fileId
    }
    
    public func queryMaxFileId() -> Int {

        var maxFileId = 0
        do {
            let sql = SafeFileInfo.filter(db_userId == FIRSTUSERID)
            maxFileId = try db.scalar(sql.select(db_selfId.max)) ?? 0
            CDPrint(item: "queryMaxFileId -->success")
        } catch {
            CDPrintManager.log("queryMaxFileId -->error:\(error)", type: .ErrorLog)
        }
        return maxFileId
    }

    public func queryAllFileFromFolder(superId: Int, sortAction: SheetItem = .timeNewOld)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            var sql = SafeFileInfo.filter(db_superId == superId)
            if sortAction == .timeNewOld {
                sql = sql.order(db_createTime.desc)
            }else if sortAction == .timeOldNew {
                sql = sql.order(db_createTime.asc)
            }else if sortAction == .fileBigsmall {
                sql = sql.order(db_size.desc)
            }else if sortAction == .filesmallBig {
                sql = sql.order(db_size.desc)
            }
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            CDPrintManager.log("queryAllFileFromFolder -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }
    
    public func updateOneSafeFileName(fileName: String, fileId: Int) {

        do {
            let sql = SafeFileInfo.filter(db_superId == fileId)
            try db.run(sql.update(db_name <- fileName))
        } catch {
            CDPrintManager.log("updateOneSafeFileName-->error:\(error)", type: .ErrorLog)
        }
    }

    /*
//     文件移动文件夹，更新文件新的folderID
//     */
//    func updateOneSafeFileFolder(fileInfo: CDSafeFileInfo) {
//        if fileInfo.filePath.hasPrefix(String.RootPath()) {
//            fileInfo.filePath = fileInfo.filePath.relativePath
//        }
//        do {
//            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)
//
//            try db.run(sql.update(db_folderId <- fileInfo.folderId))
//        } catch {
//            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
//        }
//    }

    public func deleteOneSafeFile(fileId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_selfId == fileId).delete())
        } catch {
            CDPrintManager.log("deleteOneSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteAllSubSafeFile(superId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_superId == superId).delete())
            CDPrint(item: "deleteAllSubSafeFile-->success")
        } catch {
            CDPrintManager.log("deleteAllSubSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }


}
