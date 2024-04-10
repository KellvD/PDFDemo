//
//  CDSqlManager+CDUserInfo.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//
// MARK: userInfo
import UIKit
import SQLite

extension CDSqlManager {

    internal func createUserTab() {
        do {
            let create = UserInfo.create(temporary: false, ifNotExists: false, withoutRowid: false) { (build) in
                build.column(db_userId)
                build.column(db_basePwd)
            }
            try db.run(create)
            CDPrint(item: "createUserInfo -->success")

        } catch {
            CDPrintManager.log("createUserInfo -->error:\(error)", type: .ErrorLog)
        }
    }

    public func addOneUserInfoWith(usernInfo: CDUserInfo) {
        do {
            try db.run(UserInfo.insert(
                db_userId <- usernInfo.userId,
                db_basePwd <- usernInfo.basePwd
                )
            )
            CDPrint(item: "addUserInfo -->success")
        } catch {
            CDPrintManager.log("addUserIn -->error:\(error)", type: .ErrorLog)
        }
    }


    public func queryPasscodeWithUserId() -> String? {

        var realKey: String = String()
        do {
            let sql = UserInfo.filter(db_userId == FIRSTUSERID)
            for item in try db.prepare(sql.select(db_basePwd)) {
                realKey = item[db_basePwd]
            }
            CDPrint(item: "queryPasscodeWithUserId -->success")

            return realKey.isEmpty ? nil: realKey
        } catch {
            CDPrintManager.log("queryPasscodeWithUserId -->error:\(error)", type: .ErrorLog)
            return nil

        }
    }

    public func updateUserPwdWith(pwd: String) {
        do {
            let sql = UserInfo.filter(db_userId == FIRSTUSERID)

            try db.run(sql.update(db_basePwd <- pwd))
            CDPrint(item: "updateUserRealPwdWith-->success")
        } catch {
            CDPrintManager.log("updateUserRealPwdWith-->error:\(error)", type: .ErrorLog)
        }

    }
}
