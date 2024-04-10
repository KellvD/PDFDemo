//
//  CDSqlManager.swift
//  MyRule
//
//  Created by changdong on 2018/12/10.
//  Copyright © 2018 changdong. All rights reserved.
//

import UIKit
import SQLite

class CDSqlManager: NSObject {

    static let shared = CDSqlManager()
    var db: Connection!

    private override init() {
        super.init()
        objc_sync_enter(self)
        openDatabase()
        objc_sync_exit(self)
    }

    func CDPrint(item: Any) {
        #if DEBUG
         print(item)
        #endif
    }

    private func openDatabase() {
        let documentArr: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = documentArr.first!
        let dbpath = "\(documentPath)/\(sqlFileName)"
        if !FileManager.default.fileExists(atPath: dbpath) {
            FileManager.default.createFile(atPath: dbpath, contents: nil, attributes: nil)
            do {
                db = try Connection(dbpath)
            } catch {
                assertionFailure("error:\(error)")
            }
            createTable()
        } else {
            do {
                db = try Connection(dbpath)
            } catch {
                assertionFailure("error:\(error)")
            }

        }
        upgradeDataBase()
        
    }

    private func createTable() {
        CDPrintManager.log("创建数据库表", type: .InfoLog)
        createUserTab()
        createSafeFoldeTab()
        createSafeFileInfoTab()
        createWebPageInfoTab()
        // 默添加user
        let user = CDUserInfo()
        user.userId = FIRSTUSERID
        addOneUserInfoWith(usernInfo: user)
    }
    
    
    private func upgradeDataBase() {
        
        addlifeCircle()
    }
    
    private func addlifeCircle(){
        do {
            try db.run(SafeFileInfo.addColumn(db_lifeCircle, defaultValue: NSLifeCircle.normal.rawValue))
            try db.run(SafeFolder.addColumn(db_lifeCircle, defaultValue: NSLifeCircle.normal.rawValue))
        } catch {
        }
    }

}
