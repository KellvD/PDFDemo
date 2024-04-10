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
let SafeFolder = Table("CDSafeFolder")
let WebPageInfo = Table("CDWebPageInfo")
// Mark: file

let db_id = Expression<Int>("id")
var db_folderName = Expression<String>("folderName")
var db_folderId = Expression<Int>("folderId")
var db_folderType = Expression<Int>("folderType")
var db_folderStatus = Expression<Int>("folderStatus")
var db_createTime = Expression<Int>("createTime")
var db_folderPath = Expression<String>("folderPath")
var db_isLock = Expression<Int>("isLock")
var db_fileId = Expression<Int>("fileId")
var db_fileSize = Expression<Int>("fileSize")
var db_fileWidth = Expression<Double>("fileWidth")
var db_fileHeight = Expression<Double>("fileHeight")
var db_timeLength = Expression<Double>("timeLength")
var db_fileType = Expression<Int>("fileType")
var db_fileName = Expression<String>("fileName")
var db_thumbImagePath = Expression<String>("thumbImagePath")
var db_filePath = Expression<String>("filePath")
var db_grade = Expression<Int>("grade")
var db_userId = Expression<Int>("userId")
var db_superId = Expression<Int>("superId")
var db_lifeCircle = Expression<Int>("lifeCircle")


var db_basePwd = Expression<String>("basePwd")


//
var db_webId = Expression<Int>("webId")
var db_webType = Expression<Int>("webType")
var db_webName = Expression<String>("webName")
var db_webUrl = Expression<String>("webUrl")
var db_iconImagePath = Expression<String>("iconImagePath")


