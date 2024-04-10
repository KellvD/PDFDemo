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
                build.column(db_thumbImagePath)
                build.column(db_fileName)
                build.column(db_fileId)
                build.column(db_folderId)
                build.column(db_fileSize)
                build.column(db_fileWidth)
                build.column(db_fileHeight)
                build.column(db_timeLength)
                build.column(db_createTime)
                build.column(db_fileType)
                build.column(db_filePath)
                build.column(db_grade)
                build.column(db_userId)
                build.column(db_folderType)
            }
            try db.run(create1)
            CDPrint(item: "createSafeFileInfo -->success")
        } catch {
            CDPrintManager.log("createSafeFileInfo-->error:\(error)", type: .ErrorLog)
        }
    }

    // MARK: SafeFile
    private func getSafeFileInfoFromItem(item: Row) -> CDSafeFileInfo {
        let file = CDSafeFileInfo()
        file.fileId = item[db_fileId]
        file.folderId = item[db_folderId]
        file.fileSize = item[db_fileSize]
        file.fileWidth = item[db_fileWidth]
        file.fileHeight = item[db_fileHeight]
        file.timeLength = item[db_timeLength]
        file.createTime = item[db_createTime]
        file.filePath = item[db_filePath]
        file.fileType = CDSafeFileInfo.NSFileType(rawValue: item[db_fileType])
        file.grade = CDSafeFileInfo.NSFileGrade(rawValue: item[db_grade])!
        file.fileName = item[db_fileName]
        file.thumbImagePath = item[db_thumbImagePath]
        file.userId = item[db_userId]
        file.isSelected = .no
        file.folderType = NSFolderType(rawValue: item[db_folderType])
        file.lifeCircle = NSLifeCircle(rawValue: item[db_lifeCircle])!
        return file
    }

    public func addSafeFileInfo(fileInfo: CDSafeFileInfo) -> Int {

        let fileId = queryMaxFileId() + 1
        do {
            try db.run(SafeFileInfo.insert(
                        db_fileId <- fileId,
                        db_thumbImagePath <- fileInfo.thumbImagePath,
                        db_fileName <- fileInfo.fileName,
                        db_folderId <- fileInfo.folderId,
                        db_fileSize <- fileInfo.fileSize,
                        db_fileWidth <- fileInfo.fileWidth,
                        db_fileHeight <- fileInfo.fileHeight,
                        db_timeLength <- fileInfo.timeLength,
                        db_createTime <- fileInfo.createTime,
                        db_fileType <- fileInfo.fileType!.rawValue,
                        db_grade <- CDSafeFileInfo.NSFileGrade.normal.rawValue,
                        db_filePath <- fileInfo.filePath,
                        db_userId <- FIRSTUSERID,
                        db_folderType <- fileInfo.folderType!.rawValue,
                        db_lifeCircle <- NSLifeCircle.normal.rawValue)

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
            maxFileId = try db.scalar(sql.select(db_fileId.max)) ?? 0
            CDPrint(item: "queryMaxFileId -->success")
        } catch {
            CDPrintManager.log("queryMaxFileId -->error:\(error)", type: .ErrorLog)
        }
        return maxFileId
    }

    public func queryAllFileFromFolder(folderId: Int)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId &&
                                          db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            CDPrintManager.log("queryAllFileFromFolder -->error:\(error)", type: .ErrorLog)
        }
        return fileArr
    }
    
    public func queryAllFile(with gradeType: CDSafeFileInfo.NSFileGrade)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_grade == gradeType.rawValue &&
                                          db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileArr
    }
    
    public func queryAllFile(with fileType: CDSafeFileInfo.NSFileType,folderId: Int)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_fileType == fileType.rawValue &&
                                          db_folderId == folderId &&
                                          db_lifeCircle == NSLifeCircle.normal.rawValue)
                .order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileArr
    }
    
    public func queryAllDeleteFile(folderType: NSFolderType)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_lifeCircle != NSLifeCircle.normal.rawValue &&
                                          db_folderType == folderType.rawValue).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileArr
    }
    
    public func queryAllFile(with lifeCircle: NSLifeCircle, folderType: NSFolderType)-> [CDSafeFileInfo] {
        var fileArr: [CDSafeFileInfo] = []
        do {
            let sql = SafeFileInfo.filter(db_lifeCircle == lifeCircle.rawValue &&
                                          db_folderType == folderType.rawValue).order(db_createTime.desc)
            for item in try db.prepare(sql) {
                let file = getSafeFileInfoFromItem(item: item)
                fileArr.append(file)
            }
        } catch {
            assertionFailure("error:\(error)")
        }
        return fileArr
    }

    public func queryOneSafeFileWithFileId(fileId: Int) -> CDSafeFileInfo {
        var file: CDSafeFileInfo!
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            for item in try db.prepare(sql) {
                file = getSafeFileInfoFromItem(item: item)

            }
        } catch {
            CDPrintManager.log("queryOneSafeFileWithFileId -->error:\(error)", type: .ErrorLog)
        }
        return file
    }

    func queryOneSafeFileGrade(fileId: Int) -> CDSafeFileInfo.NSFileGrade {
        var grade = CDSafeFileInfo.NSFileGrade.normal
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)

            for item in try db.prepare(sql.select(db_grade)) {
                grade = CDSafeFileInfo.NSFileGrade(rawValue: item[db_grade])!

            }
        } catch {
            CDPrintManager.log("queryOneSafeFileGrade -->error:\(error)", type: .ErrorLog)
        }
        return grade
    }
    
    public func queryOneFileForFolderCoverImage(with folder: CDSafeFolder) -> CDSafeFileInfo {
        var file =  CDSafeFileInfo()
        do {
            var sql:QueryType
            if folder.folderStatus == .Custom || folder.folderStatus == .All {
                sql = SafeFileInfo.filter(db_folderId == folder.folderId && db_lifeCircle == NSLifeCircle.normal.rawValue).order(db_fileId.desc).limit(1)
            } else if folder.folderStatus == .Delete {
                sql = SafeFileInfo.filter(db_folderType == NSFolderType.Media.rawValue && db_lifeCircle == NSLifeCircle.delete.rawValue).order(db_fileId.desc).limit(1)
            } else {
                sql = SafeFileInfo.filter(db_grade == CDSafeFileInfo.NSFileGrade.lovely.rawValue).order(db_fileId.desc).limit(1)
            }
            
            for item in try db.prepare(sql) {
                file = getSafeFileInfoFromItem(item: item)
            }
        } catch {
            CDPrintManager.log("queryOneSafeFileGrade -->error:\(error)", type: .ErrorLog)
        }
        return file
    }
    
    public func queryAllUnReadDeleteFile(type: NSFolderType) -> Int {
        var totalCount = 0
        let sql = SafeFileInfo.filter(db_folderType == type.rawValue && db_lifeCircle == NSLifeCircle.delete.rawValue)
        do {
            totalCount = try db.scalar(sql.count)
        } catch {
            assertionFailure("error:\(error)")
        }
        return totalCount

    }
    
    public func updateOneSafeFileName(fileName: String, fileId: Int) {

        do {
            let sql = SafeFileInfo.filter(db_fileId == fileId)
            try db.run(sql.update(db_fileName <- fileName))
        } catch {
            CDPrintManager.log("updateOneSafeFileName-->error:\(error)", type: .ErrorLog)
        }
    }

    func updateOneSafeFileGrade(with grade: CDSafeFileInfo.NSFileGrade, fileId: Int) {
        do {
            let sql = SafeFileInfo.filter((db_fileId == fileId)&&(db_userId == FIRSTUSERID))
            try db.run(sql.update(db_grade <- grade.rawValue))
        } catch {
            CDPrintManager.log("updateOneSafeFileGrade-->error:\(error)", type: .ErrorLog)
        }
    }
    
    func updateOneSafeFileLifeCircle(with lifeCircle: NSLifeCircle, fileId: Int) {
        do {
            let sql = SafeFileInfo.filter((db_fileId == fileId)&&(db_userId == FIRSTUSERID))
            try db.run(sql.update(db_lifeCircle <- lifeCircle.rawValue))
        } catch {
            assertionFailure("error:\(error)")
        }
    }
    
    func updateAllDeleteFileIsRead(with type: NSFolderType) {
        do {
            let sql = SafeFileInfo.filter(db_folderType == type.rawValue && db_lifeCircle == NSLifeCircle.delete.rawValue)
            try db.run(sql.update(db_lifeCircle <- NSLifeCircle.deleteHasRead.rawValue))
        } catch {
            assertionFailure("error:\(error)")
        }
    }
    
    func updateOneSafeFile(with lifeCircle: NSLifeCircle, folderId: Int) {
        do {
            let sql = SafeFileInfo.filter(db_folderId == folderId)
            try db.run(sql.update(db_lifeCircle <- lifeCircle.rawValue))
        } catch {
            CDPrintManager.log("updateOneSafeFileGrade-->error:\(error)", type: .ErrorLog)
        }
    }

    /*
     文件移动文件夹，更新文件新的folderID
     */
    func updateOneSafeFileFolder(fileInfo: CDSafeFileInfo) {
        if fileInfo.filePath.hasPrefix(String.RootPath()) {
            fileInfo.filePath = fileInfo.filePath.relativePath
        }
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(db_folderId <- fileInfo.folderId))
        } catch {
            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
        }
    }

    func updateOneSafeFileInfo(fileInfo: CDSafeFileInfo) {
        do {
            let sql = SafeFileInfo.filter(db_fileId == fileInfo.fileId)

            try db.run(sql.update(
                                  db_thumbImagePath <- fileInfo.thumbImagePath,
                                  db_fileName <- fileInfo.fileName,
                                  db_folderId <- fileInfo.folderId,
                                  db_fileSize <- fileInfo.fileSize,
                                  db_fileWidth <- fileInfo.fileWidth,
                                  db_fileHeight <- fileInfo.fileHeight,
                                  db_timeLength <- fileInfo.timeLength,
                                  db_createTime <- fileInfo.createTime,
                                  db_fileType <- fileInfo.fileType!.rawValue,
                                  db_grade <- fileInfo.grade.rawValue,
                                  db_filePath <- fileInfo.filePath,
                                  db_userId <- fileInfo.userId,
                                  db_folderType <- fileInfo.folderType!.rawValue))
        } catch {
            CDPrintManager.log("updateOneSafeFileForMove-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteOneSafeFile(fileId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_fileId == fileId).delete())
            // delete from SafeFile where db_fileId = fileId
        } catch {
            CDPrintManager.log("deleteOneSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }

    public func deleteAllSubSafeFile(folderId: Int) {
        do {
            try db.run(SafeFileInfo.filter(db_folderId == folderId).delete())
            CDPrint(item: "deleteAllSubSafeFile-->success")
        } catch {
            CDPrintManager.log("deleteAllSubSafeFile-->error:\(error)", type: .ErrorLog)
        }
    }


}
