//
//  CDSqlDefines.swift
//  MyBox
//
//  Created by changdong on 2021/9/18.
//  Copyright © 2018 changdong. All rights reserved.
//

import Foundation
import SQLite
let sqlFileName = "CDSQL.db"

let SafeFileInfo = Table("CDSafeFileInfo")
let UserInfo = Table("CDUserInfo")
// Mark: file

let db_id = Expression<Int>("id")
var db_selfId = Expression<Int>("selfId")
var db_userId = Expression<Int>("userId")
var db_size = Expression<Int>("size")
var db_createTime = Expression<Int>("createTime")
var db_type = Expression<Int>("type")
var db_name = Expression<String>("name")
var db_thumbPath = Expression<String>("thumbPath")
var db_path = Expression<String>("path")
var db_superId = Expression<Int>("superId")
var db_lock = Expression<Int>("lock")

var db_basePwd = Expression<String>("basePwd")

