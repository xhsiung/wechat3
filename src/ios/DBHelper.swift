//
//  DBHelper.swift
//  App
//
//  Created by Pan Alex on 2017/5/15.
//  Copyright © 2017年 Pan Alex. All rights reserved.
//
import Foundation
import SQLite

class DBHelper {
    static var dbhelper:DBHelper?
    var db:Connection?
    static var OWNER:JSON = [:]
    var ContactsDB:JSON?
    var hasChatHistoryLastRow = false
    
    let tbChatHistory = Table("ChatHistory")
    let chatHistoryId = Expression<Int>("_id")
    let chatHistoryCid = Expression<String>("cid")
    let chatHistoryChannel = Expression<String>("channel")
    let chatHistoryAction = Expression<String>("action")
    let chatHistorySid = Expression<String>("sid")
    
    let chatHistoryTid = Expression<String>("tid")
    let chatHistoryGid = Expression<String>("gid")
    let chatHistoryCorps = Expression<Int>("corps")
    let chatHistoryCategory = Expression<String>("category")
    let chatHistoryData = Expression<String>("data")
    
    let chatHistoryStatus = Expression<Int>("status")
    let chatHistoryCreatedTime = Expression<String>("created_time")
    let chatHistoryUpdatedTime = Expression<String>("updated_time")
    let chatHistoryLocationName = Expression<String>("location_name")
    let chatHistoryLocationAddress = Expression<String>("location_address")
    
    let chatHistoryLocationPhone = Expression<String>("location_phone")
    let chatHistoryLocationLatitude  = Expression<Int>("location_latitude")
    let chatHistoryLocationLongitude = Expression<Int>("location_longitude")
    let chatHistoryFlag = Expression<Int>("flag")
    
    
    let tbContacts = Table("Contacts")
    let contactsMid = Expression<String>("m_id")
    let contactsCustomName = Expression<String>("custom_name")
    let contactsAddressBook = Expression<String>("addressbook")
    let contactsSex = Expression<String>("sex")
    let contactsBirth = Expression<String>("birth")
    
    let contactsEmail = Expression<String>("email")
    let contactsPhone = Expression<String>("phone")
    let contactsMobile = Expression<String>("mobile")
    let contactsGrade = Expression<String>("grade")
    let contactsCorps = Expression<Int>("corps")
    
    let contactsIsLock = Expression<Int>("islock")
    let contactsIsGroup = Expression<Int>("isgroup")
    let contactsXGroup = Expression<String>("xgroup")
    let contactsPeoNums = Expression<Int>("peonums")
    let contactsPicturePath = Expression<String>("picture_path")
    
    let contactsCreatedTime = Expression<String>("created_time")
    let contactsUpdatedTime = Expression<String>("updated_time")
    let contactsId = Expression<String>("contact_id")
    let contactsKey = Expression<String>("contact_key")
    let contactsStatusMsg = Expression<String>("status_msg")
    
    let contactsUlastUpdatedTime = Expression<String>("ulast_updated_time")
    let contactsGlastUpdatedTime = Expression<String>("glast_updated_time")
    let contactsOthers = Expression<String>("others")
    
    //ChatSyncsTS Table
    let tbChatSyncs = Table("ChatSyncsTS")
    let chatsyncAction  = Expression<String>("action") //primary key
    let chatsyncChannel = Expression<String>("channel")
    let chatsyncSid = Expression<String>("sid")
    let chatsyncStartTime = Expression<String>("starttime")
    let chatsyncEndTime = Expression<String>("endtime")
    
    //OpenRooms
    let tbOpenRooms = Table("OpenRooms")
    let openroomId = Expression<Int>("id")
    let openroomChannel = Expression<String>("channel")
    let openroomSid = Expression<String>("sid")
    let openroomStartTime = Expression<String>("starttime")
    let openroomEndTime = Expression<String>("endtime")
    
    //ChatTsFlag
    let tbChatTsFlag = Table("ChatTsFlas")
    let chattsflagFlag = Expression<String>("flag")
    let chattsflagTs = Expression<String>("ts")
    
    //ChatNews
    let tbChatNews = Table("ChatNews")
    let chatnewsId = Expression<Int>("id")
    let chatnewsTitle = Expression<String>("title")
    let chatnewsContent = Expression<String>("content")
    let chatnewsCreatedTime = Expression<String>("created_time")
    
    
    static func getInstance()->DBHelper {
        if dbhelper == nil {
            dbhelper = DBHelper()
        }
        return dbhelper!
    }
    
    init(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        print("sqlite location:\(path)")
        
        do {
            try db = Connection("\(path)/wechat.sqlit3")
            createChatHistory()
            createContacts()
            createChatSyncsTS()
            createOpenRooms()
            createChatTsFlag()
            createChatNews()
            
        } catch {
            print("DBHelper init Error: \(error)")
        }
    }
    
    
    func createChatHistory() {
        do {
            try db!.run(tbChatHistory.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(chatHistoryId, primaryKey: .autoincrement)
                tb.column(chatHistoryCid)
                tb.column(chatHistoryChannel)
                tb.column(chatHistoryAction)
                tb.column(chatHistorySid)
                
                tb.column(chatHistoryTid)
                tb.column(chatHistoryGid)
                tb.column(chatHistoryCorps)
                tb.column(chatHistoryCategory)
                tb.column(chatHistoryData)
                
                tb.column(chatHistoryStatus)
                tb.column(chatHistoryCreatedTime)
                tb.column(chatHistoryUpdatedTime)
                tb.column(chatHistoryLocationName)
                tb.column(chatHistoryLocationAddress)
                
                tb.column(chatHistoryLocationPhone)
                tb.column(chatHistoryLocationLatitude)
                tb.column(chatHistoryLocationLongitude)
                tb.column(chatHistoryFlag)
            }))
            
        } catch {
            print("createChatHistory Error: \(error)")
        }
    }
    
    func createContacts(){
        do {
            try db!.run(tbContacts.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(contactsMid, primaryKey:true)
                tb.column(contactsCustomName)
                tb.column(contactsAddressBook)
                tb.column(contactsSex)
                tb.column(contactsBirth)
                
                tb.column(contactsEmail)
                tb.column(contactsPhone)
                tb.column(contactsMobile)
                tb.column(contactsGrade)
                tb.column(contactsCorps)
                
                tb.column(contactsIsLock)
                tb.column(contactsIsGroup)
                tb.column(contactsXGroup)
                tb.column(contactsPeoNums)
                tb.column(contactsPicturePath)
                
                tb.column(contactsCreatedTime)
                tb.column(contactsUpdatedTime)
                tb.column(contactsId)
                tb.column(contactsKey)
                tb.column(contactsStatusMsg)
                
                tb.column(contactsUlastUpdatedTime)
                tb.column(contactsGlastUpdatedTime)
                tb.column(contactsOthers)
            }))
        } catch{
            print("createContacts Error: \(error)")
        }
    }
    
    func createChatSyncsTS(){
        do {
            try db!.run(tbChatSyncs.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(chatsyncAction , primaryKey: true)
                tb.column(chatsyncChannel)
                tb.column(chatsyncSid)
                tb.column(chatsyncStartTime)
                tb.column(chatsyncEndTime)
            }))
        } catch{
            print("createChatSyncsTS Error: \(error)")
        }
    }
    
    func createOpenRooms(){
        do {
            try db!.run(tbOpenRooms.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(openroomId , primaryKey: .autoincrement)
                tb.column(openroomChannel)
                tb.column(openroomSid)
                tb.column(openroomStartTime)
                tb.column(openroomEndTime)
            }))
        } catch{
            print("createOpenRooms Error: \(error)")
        }
    }
    
    func createChatTsFlag(){
        do {
            try db!.run(tbChatTsFlag.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(chattsflagFlag , primaryKey: true)
                tb.column(chattsflagTs)
                
            }))
        } catch {
            print("createChatTsFlag Error: \(error)")
        }
    }
    
    func createChatNews(){
        do {
            try db!.run(tbChatNews.create(temporary: false, ifNotExists: true, withoutRowid: false, block: { (tb) in
                tb.column(chatnewsId , primaryKey: .autoincrement)
                tb.column(chatnewsTitle)
                tb.column(chatnewsContent)
                tb.column(chatnewsCreatedTime)
            }))
        } catch {
            print("createChatNews Error: \(error)")
        }
    }
    
    
    //data is array
    func updateInsertChatHistory( data:JSON , action:String="send", status:Int = 0 ) {
        print("DBHelper updateInsertChatHistory")
        do {
            
            for (_,jobj):(String, JSON) in data["data"] {
                //print(jobj["sid"].stringValue )
                
                //print( jobj )
                var xjobj = jobj
                if ( action.contains("send") || action.contains("notify") || action.contains("invite")){
                    xjobj.dictionaryObject?.removeValue(forKey: "status")
                    try xjobj.merge(with: JSON(["status": status ]))
                }
                
                let count = try db?.scalar( tbChatHistory.filter( chatHistoryCid == xjobj["cid"].stringValue ).count)
                
                if count! > 0 {
                    //update
                    _ = updateChatHistory(data: xjobj)
                }else{
                    //insert
                    _ = insertChatHistory(data: xjobj )
                }
            }
            
        } catch{
            print("updelChatHistory Error:\(error)")
        }
        
    }
    
    
    func updateInsertChatHistory(data:JSON ,channel:String , status: Int )    {
        do {
            for (_,jobj):(String, JSON) in data["data"] {
                var xjobj = jobj
                let count = try db?.scalar( tbChatHistory.filter( chatHistoryCid == xjobj["cid"].stringValue ).count)
                
                if xjobj["channel"].stringValue == channel {
                    xjobj.dictionaryObject?.removeValue(forKey: "status")
                    try xjobj.merge(with: JSON(["status": status]))
                }
                
                if count! > 0 {
                    //update
                    _ = updateChatHistory(data: xjobj)
                }else{
                    //insert
                    _ = insertChatHistory(data: xjobj )
                }
            }
            
        } catch {
            print("updateInsertChatHistory Error:\(error)")
        }
    }
    
    
    func deleteChatHistory(data:JSON) -> Bool {
        print("DBHelper deleteChatHistory")
        do {
            let filterparam = data["cid"].exists() ? data["cid"].stringValue : (data["cid"].exists() ? data["channel"].stringValue:"" )
            if filterparam.isEmpty { return false }
            
            let tbFilterChatHistory = tbChatHistory.filter( chatHistoryCid == filterparam )
            let xdelete = tbFilterChatHistory.delete()
            try db?.run(xdelete)
            return true
        } catch {
            return false
        }
    }
    
    func insertChatHistory(data:JSON) -> Bool{
        print("DBHelper insertChatHistory")
        do {
            let xinsert = tbChatHistory.insert(chatHistoryCid <- data["cid"].stringValue,
                                               chatHistoryChannel <- data["channel"].stringValue,
                                               chatHistoryAction <- data["action"].stringValue,
                                               chatHistorySid <- data["sid"].stringValue,
                                               chatHistoryTid <- data["tid"].stringValue,
                                               chatHistoryGid <- data["gid"].stringValue,
                                               chatHistoryCorps <- data["corps"].intValue,
                                               chatHistoryCategory <- data["category"].stringValue,
                                               chatHistoryData <- data["data"].stringValue,
                                               chatHistoryStatus <- data["status"].intValue,
                                               chatHistoryCreatedTime <- data["created_time"].stringValue,
                                               chatHistoryUpdatedTime <- data["updated_time"].stringValue,
                                               chatHistoryLocationName <- data["location_name"].stringValue,
                                               chatHistoryLocationAddress <- data["location_address"].stringValue,
                                               chatHistoryLocationPhone <- data["location_phone"].stringValue,
                                               chatHistoryLocationLatitude <- data["location_latitude"].intValue,
                                               chatHistoryLocationLongitude <- data["location_longitude"].intValue,
                                               chatHistoryFlag <- data["flag"].intValue)
            try db?.run(xinsert)
            return true
        } catch  {
            print("inertChatHistory Error:\(error)")
            return false
        }
    }
    
    
    func updateChatHistory(data: JSON ) -> Bool {
        print("DBHelper updateChatHistory")
        do {
            let tbFilterChatHistory = tbChatHistory.filter( chatHistoryCid == data["cid"].stringValue)
            //let xupdate = tbFilterChatHistory.update([chatHistoryStatus <- data["status"].intValue,
            //                                          chatHistoryFlag <- data["flag"].intValue])
            
            let xupdate = tbFilterChatHistory.update([ chatHistoryChannel <- data["channel"].stringValue,
                                                       chatHistoryAction <- data["action"].stringValue,
                                                       chatHistorySid <- data["sid"].stringValue,
                                                       chatHistoryTid <- data["tid"].stringValue,
                                                       chatHistoryGid <- data["gid"].stringValue,
                                                       chatHistoryCorps <- data["corps"].intValue,
                                                       chatHistoryCategory <- data["category"].stringValue,
                                                       chatHistoryData <- data["data"].stringValue,
                                                       chatHistoryStatus <- data["status"].intValue,
                                                       chatHistoryCreatedTime <- data["created_time"].stringValue,
                                                       chatHistoryUpdatedTime <- data["updated_time"].stringValue,
                                                       chatHistoryLocationName <- data["location_time"].stringValue,
                                                       chatHistoryLocationAddress <- data["location_address"].stringValue,
                                                       chatHistoryLocationPhone <- data["location_phone"].stringValue,
                                                       chatHistoryLocationLatitude <- data["location_latitude"].intValue,
                                                       chatHistoryLocationLongitude <- data["location_longitude"].intValue,
                                                       chatHistoryFlag <- data["flag"].intValue] )
            
            try db?.run(xupdate)
            return true
        } catch {
            print("updateChatHistory Error:\(error)")
            return false
        }
    }
    
    
    //update chatHistory status
    func updateChatHistoryStatus(action:String , channel:String , status:Int ) -> Bool {
        do {
            let tbFilterChatHistory = tbChatHistory.filter(chatHistoryAction == action && chatHistoryChannel == channel)
            let xupdate = tbFilterChatHistory.update([ chatHistoryStatus <- status])
            try db?.run(xupdate)
            return true
        } catch {
            print("updateChatHistoryStatus Error:\(error)")
            return false
        }
    }
    
    
    func queryUnreadChatHistory(action:String) -> JSON {
        print("queryUnreadChatHistory")
        do {
            var tbquery = tbChatHistory.filter( chatHistoryAction == action && chatHistoryStatus == 0 && chatHistoryFlag == -1).order( chatHistoryUpdatedTime.desc )
            
            var arrow = [JSON]()
            for row in try db!.prepare(tbquery) {
                let xrow = JSON( ["cid":row[chatHistoryCid],
                                  "channel":row[chatHistoryChannel],
                                  "action":row[chatHistoryAction],
                                  "sid":row[chatHistorySid],
                                  "tid":row[chatHistoryTid],
                                  "gid":row[chatHistoryGid],
                                  "corps":row[chatHistoryCorps],
                                  "category":row[chatHistoryCategory],
                                  "data":row[chatHistoryData],
                                  "status":row[chatHistoryStatus],
                                  "created_time":row[chatHistoryCreatedTime],
                                  "updated_time":row[chatHistoryUpdatedTime],
                                  "location_time":row[chatHistoryLocationName],
                                  "location_address":row[chatHistoryLocationAddress],
                                  "location_phone":row[chatHistoryLocationPhone],
                                  "location_latitude":row[chatHistoryLocationLatitude],
                                  "location_longitude":row[chatHistoryLocationLongitude],
                                  "flag":row[chatHistoryFlag]] )
                arrow.append(xrow)
            }
            
            return JSON(["data": arrow])
        } catch {
            print("queryUnreadChatHistory Error:\(error)")
            return JSON([:])
        }
    }
    
    
    //get Last Row ChatHistory timstamp
    func getChatHistoryLastRow() -> JSON {
        var jsonData:JSON = JSON([:])
        
        do {
            let query = tbChatHistory.filter(chatHistoryFlag == -1).order(chatHistoryUpdatedTime.desc).limit(1)
            //let rowarr = try db?.prepare(query)
            
            for row in try db!.prepare( query ){
                jsonData = JSON([ "cid": row[chatHistoryCid],
                                  "channel":row[chatHistoryChannel],
                                  "action":row[chatHistoryAction],
                                  "sid":row[chatHistorySid],
                                  "tid":row[chatHistoryTid],
                                  "gid":row[chatHistoryGid],
                                  "corps":row[chatHistoryCorps],
                                  "category":row[chatHistoryCategory],
                                  "data":row[chatHistoryData],
                                  "status":row[chatHistoryStatus],
                                  "created_time":row[chatHistoryCreatedTime],
                                  "updated_time":row[chatHistoryUpdatedTime],
                                  "location_time":row[chatHistoryLocationName],
                                  "location_address":row[chatHistoryLocationAddress],
                                  "location_phone":row[chatHistoryLocationPhone],
                                  "location_latitude":row[chatHistoryLocationLatitude],
                                  "location_longitude":row[chatHistoryLocationLongitude],
                                  "flag":row[chatHistoryFlag] ])
            }
            
            hasChatHistoryLastRow = ( jsonData.dictionary?.count == 0 ) ? false : true
            return jsonData
        } catch{
            print("getChatHistoryLastRow Error:\(error)")
            return jsonData
        }
    }
    
    
    func getChatHistoryUndeliverd() -> JSON {
        
        do {
            var jarr = [JSON]()
            let query = tbChatHistory.filter(chatHistoryFlag == 0).order(chatHistoryUpdatedTime.asc)
            for row in try db!.prepare( query ){
                jarr.append( JSON([ "cid": row[chatHistoryCid],
                                    "channel":row[chatHistoryChannel],
                                    "action":row[chatHistoryAction],
                                    "sid":row[chatHistorySid],
                                    "tid":row[chatHistoryTid],
                                    "gid":row[chatHistoryGid],
                                    "corps":row[chatHistoryCorps],
                                    "category":row[chatHistoryCategory],
                                    "data":row[chatHistoryData],
                                    "status":row[chatHistoryStatus],
                                    "created_time":row[chatHistoryCreatedTime],
                                    "updated_time":row[chatHistoryUpdatedTime],
                                    "location_time":row[chatHistoryLocationName],
                                    "location_address":row[chatHistoryLocationAddress],
                                    "location_phone":row[chatHistoryLocationPhone],
                                    "location_latitude":row[chatHistoryLocationLatitude],
                                    "location_longitude":row[chatHistoryLocationLongitude],
                                    "flag":row[chatHistoryFlag] ]) )
                
            }
            
            return JSON(["data": jarr])
        } catch{
            print("getChatHistoryUndeliverd Error:\(error)")
            return JSON(["data":[:]] )
        }
    }
    
    
    func queryGroupChatHistory() -> JSON {
        
        do {
            let sql = "SELECT * FROM (SELECT * FROM ChatHistory WHERE flag=-1 AND action='send' ORDER BY updated_time) temp GROUP BY channel ORDER BY updated_time DESC"
            
            var jarr = [JSON]()
            for row in try db!.prepare(sql) {
                //let _id = row[0]! //_id
                //let cid = row[1]! as! String //cid
                let channel = row[2]! as! String //channel
                //let action = row[3]! as! String //action
                let sid = row[4]! as! String   //sid
                
                let tid = row[5]! as! String//tid
                let gid = row[6]! as! String//gid
                //let corps = row[7]! as! Int64//corps
                //let category = row[8]! as! String//category
                let data = row[9]! as! String //data
                
                //let status = row[10]! as! Int64//status
                //let created_time = row[11]! as! String//created_time
                let updated_time = row[12]! as! String//updated_time
                //let location_name = row[13]! as! String//location_name
                //let location_address = row[14]! as! String//location_address
                
                //let location_phone = row[15]! as! String//location_phone
                //let location_latitude = row[16]! as! Int64//location_latitude
                //let location_longitude = row[17]! as! Int64//location_longitude
                //let flag = row[18]! as! Int64//flag
                
                let user = getContactsUser(m_id: sid )
                let custom_name = user["custom_name"].stringValue
                let peonums = user["peonums"].intValue
                
                let isgroup = gid.isEmpty ? 0 : 1
                
                //unreadrows
                let sql2 = "SELECT count(*) FROM ChatHistory WHERE action='send' AND status=0 AND channel='\(channel)'"
                let count = try db?.scalar(sql2) as! Int64
                
                jarr.append(JSON(["channel": channel,
                                  "sid": sid,
                                  "tid": tid,
                                  "gid": gid,
                                  "data":"",
                                  "last_message":data,
                                  "last_created_time": updated_time,
                                  "isgroup": isgroup,
                                  "chat_name": custom_name,
                                  "peonums": peonums,
                                  "unread": count
                    ] ))
            }
            
            //print( JSON(["data": jarr ]) )
            return JSON(["data":jarr ])
        } catch {
            print("queryChatHistoryGroup Error:\(error)")
            return JSON(["data":[:] ])
        }
    }
    
    
    func queryDBDate(data:JSON) -> JSON {
        do {
            var jarr = [JSON]()
            let channel = data["channel"].stringValue
            let offset = data["offset"].intValue
            let limit = data["limit"].intValue
            
            let query = tbChatHistory.filter( chatHistoryAction == "send" && chatHistoryFlag == -1 && chatHistoryChannel == channel).order(chatHistoryUpdatedTime.desc).limit(limit , offset: offset)
            for row in try db!.prepare( query ){
                jarr.append( JSON([ "cid": row[chatHistoryCid],
                                    "channel":row[chatHistoryChannel],
                                    "action":row[chatHistoryAction],
                                    "sid":row[chatHistorySid],
                                    "tid":row[chatHistoryTid],
                                    "gid":row[chatHistoryGid],
                                    "corps":row[chatHistoryCorps],
                                    "category":row[chatHistoryCategory],
                                    "data":row[chatHistoryData],
                                    "status":row[chatHistoryStatus],
                                    "created_time":row[chatHistoryCreatedTime],
                                    "updated_time":row[chatHistoryUpdatedTime],
                                    "location_time":row[chatHistoryLocationName],
                                    "location_address":row[chatHistoryLocationAddress],
                                    "location_phone":row[chatHistoryLocationPhone],
                                    "location_latitude":row[chatHistoryLocationLatitude],
                                    "location_longitude":row[chatHistoryLocationLongitude],
                                    "flag":row[chatHistoryFlag] ]) )
            }
            
            return JSON(["data": jarr])
        } catch  {
            print("queryDBDate Error:\(error)")
            return JSON(["data": [:] ])
        }
        
    }
    
    func hasContacts(m_id:String) -> Bool {
        ContactsDB = ( ContactsDB == nil ) ? getContacts() : ContactsDB
        
        for user in ContactsDB!["data"].array! {
            if user["m_id"].stringValue == m_id {
                return true
            }
        }
        
        return false
    }
    
    func getContactsUser( m_id:String  ) -> JSON {
        print("DBHelper getContactsUser")
        ContactsDB = ( ContactsDB == nil ) ? getContacts() : ContactsDB
        
        for user in (ContactsDB!["data"].array)! {
            if user["m_id"].stringValue == m_id {
                return user
            }
        }
        
        return JSON([:])
    }
    
    
    func getOwner() -> JSON{
        
        if DBHelper.OWNER.dictionary!.count != 0 {
            return DBHelper.OWNER
        }
        
        ContactsDB = ( ContactsDB == nil ) ? getContacts() : ContactsDB
       
        
        for user in (ContactsDB!["data"].array)! {
            //owner
            if user["corps"].intValue == -1 {
                DBHelper.OWNER = user
            }
        }
        return DBHelper.OWNER
    }
    
    func getContactsGroup() -> [JSON] {
        print("DBHelper getContactsGroup")
        ContactsDB = ( ContactsDB == nil ) ? getContacts() : ContactsDB
        
        var grouparr = [JSON]()
        for user in (ContactsDB!["data"].array)! {
            //group
            if user["isgroup"].intValue == 1 {
                grouparr.append(user)
            }
        }
        
        return grouparr
    }
    
    func getContacts() -> JSON {
        print("DBHelper getContacts")
        do {
            if ContactsDB != nil {
                return ContactsDB!
            }
            
            var userarr = [JSON]()
            for row in try db!.prepare( tbContacts.order(contactsCorps.desc) ) {
                //print( owner[contactsMid] )
                let json = JSON(["m_id":row[contactsMid],
                                 "custom_name":row[contactsCustomName],
                                 "addressbook":row[contactsAddressBook],
                                 "sex":row[contactsSex],
                                 "birth":row[contactsBirth],
                                 "email":row[contactsEmail],
                                 "phone":row[contactsPhone],
                                 "mobile":row[contactsMobile],
                                 "grade":row[contactsGrade],
                                 "corps":row[contactsCorps],
                                 "islock":row[contactsIsLock],
                                 "isgroup":row[contactsIsGroup],
                                 "xgroup":row[contactsXGroup],
                                 "peonums":row[contactsPeoNums],
                                 "picture_path":row[contactsPicturePath],
                                 "created_time":row[contactsCreatedTime],
                                 "updated_time":row[contactsUpdatedTime],
                                 "contact_id":row[contactsId],
                                 "contact_key":row[contactsKey],
                                 "status_msg":row[contactsStatusMsg],
                                 "ulast_updated_time":row[contactsUlastUpdatedTime],
                                 "glast_updated_time":row[contactsGlastUpdatedTime],
                                 "others":row[contactsOthers]
                                ])
                userarr.append(json)
            }
            
            ContactsDB = JSON( ["data":userarr] )
            return ContactsDB!
            
        } catch {
            print("DBHelper getContacts Error:\(error)")
            return JSON(["data":[] ])
        }
    }
    
    
    //data is array
    func operatorContacts(data:JSON) -> Bool{
        print("DBHelper operatorContacts")
        for (_,Json):(String, JSON) in data {
            //Do something you want
            var json = getDefaultContact(data: Json)
            ContactsDB = nil
            switch json["action"].stringValue {
            case "insert":
                print("DBHelper operatorContacts insert")
                let success = insertContacts(data: json)
                if !success {
                    return false
                }
                
            case "update":
                print("DBHelper operatorContacts update")
                let success = updateContacts(data: json)
                if !success {
                    return false
                }
                
            case "delete":
                print("DBHelper operatorContacts delete")
                let success = deleteContacts(data: json)
                if !success {
                    return false
                }
                
            case "deleteall":
                print("DBHelper operatorContacts deleteall")
                let success = deleteallContacts(data: json)
                if !success {
                    return false
                }
            default:
                break
            }
        }
        return true
    }
    
    func updateContacts(data:JSON) -> Bool{
        do {
            let tbFilterContacts = tbContacts.filter( contactsMid == data["m_id"].stringValue)
            let xupdate = tbFilterContacts.update([contactsCustomName <- data["custom_name"].stringValue,
                                                   contactsAddressBook <- data["addressbook"].stringValue,
                                                   contactsSex <- data["sex"].stringValue,
                                                   contactsBirth <- data["birth"].stringValue,
                                                   contactsEmail <- data["email"].stringValue,
                                                   contactsPhone <- data["phone"].stringValue,
                                                   contactsMobile <- data["mobile"].stringValue,
                                                   contactsGrade <- data["grade"].stringValue,
                                                   contactsCorps <- data["corps"].intValue,
                                                   contactsIsLock <- data["islock"].intValue,
                                                   contactsIsGroup <- data["isgroup"].intValue,
                                                   contactsXGroup <- data["xgroup"].stringValue,
                                                   contactsPeoNums <- data["peonums"].intValue,
                                                   contactsUlastUpdatedTime <- data["ulast_updated_time"].stringValue,
                                                   contactsGlastUpdatedTime <- data["glast_updated_time"].stringValue,
                                                   contactsOthers <- data["others"].stringValue ])
            try db!.run(xupdate)
            return true
        } catch {
            print("DBHelper updateContacts Error:\(error)")
            return false
        }
    }
    
    
    func deleteContacts(data:JSON) -> Bool{
        do {
            let tbFilterContacts = tbContacts.filter( contactsMid == data["m_id"].stringValue)
            try db!.run(tbFilterContacts.delete())
            return true
        } catch {
            print("DBHelper deleteContacts Error:\(error)")
            return false
        }
    }
    
    
    func deleteallContacts(data:JSON) -> Bool {
        do {
            try db!.run(tbContacts.delete())
            return true
        } catch {
            print("DBHelper delteContatcs Error:\(error)")
            return false
        }
    }
    
    
    func insertContacts(data:JSON) -> Bool{
        do {
            let xinsert = tbContacts.insert(contactsMid <- data["m_id"].stringValue,
                                            contactsCustomName <- data["custom_name"].stringValue,
                                            contactsAddressBook <- data["addressbook"].stringValue,
                                            contactsSex <- data["sex"].stringValue,
                                            contactsBirth <- data["birth"].stringValue,
                                            
                                            contactsEmail <- data["email"].stringValue,
                                            contactsPhone <- data["phone"].stringValue,
                                            contactsMobile <- data["mobile"].stringValue,
                                            contactsGrade <- data["grade"].stringValue,
                                            contactsCorps <- data["corps"].intValue,
                                            
                                            contactsIsLock <- data["islock"].intValue,
                                            contactsIsGroup <- data["isgroup"].intValue,
                                            contactsXGroup <- data["xgroup"].stringValue,
                                            contactsPeoNums <- data["peonums"].intValue,
                                            contactsPicturePath <- data["picture_path"].stringValue,
                                            
                                            contactsCreatedTime <- data["created_time"].stringValue,
                                            contactsUpdatedTime <- data["updated_time"].stringValue,
                                            contactsId <- data["contact_id"].stringValue,
                                            contactsKey <- data["contact_key"].stringValue,
                                            contactsStatusMsg <- data["status_msg"].stringValue,
                                            
                                            contactsStatusMsg <- data["status_msg"].stringValue,
                                            contactsUlastUpdatedTime <- data["ulast_updated_time"].stringValue,
                                            contactsGlastUpdatedTime <- data["glast_updated_time"].stringValue,
                                            contactsOthers <- data["others"].stringValue)
            try db?.run(xinsert)
            return true
        } catch {
            print("insertContacts Error:\(error)")
            return false
        }
    }
    
    
    func queryChatNews(data:JSON) -> JSON {
        do {
            var jarr = [JSON]()
            let channel = data["channel"].stringValue
            let offset = data["offset"].intValue
            let limit = data["limit"].intValue
            
            let query = tbChatNews.order(chatnewsCreatedTime.asc).limit(limit, offset: offset)
            
            for row in try db!.prepare( query ) {
                jarr.append( JSON([ "id": row[ chatnewsId ],
                                    "title": row[chatnewsTitle],
                                    "content": row[chatnewsContent],
                                    "created_time":row[chatnewsCreatedTime] ]) )
            }
            
            return JSON(["data": jarr ])
        }catch{
            print("queryChatNews Error:\(error))")
        }
        
        return JSON([:])
    }
    
    
    func insertChatNews(data:JSON ) -> Bool{
        do {
            for (_,jobj):(String, JSON) in data["data"] {
                let xinsert = tbChatNews.insert(chatnewsTitle <- jobj["title"].stringValue,
                                                chatnewsContent <- jobj["content"].stringValue,
                                                chatnewsCreatedTime <- jobj["created_time"].stringValue )
                try db?.run(xinsert)
            }
            
            return true
        } catch {
            print("inertChatNews Error:\(error)")
            return false
        }
    }
    
    
    func updateInertChatTsFlag(data:JSON) -> Bool {
        do {
            
            let tbFilterChatTsFlag = tbChatTsFlag.filter( chattsflagFlag == data["flag"].stringValue)
            let count = try db?.scalar( tbFilterChatTsFlag.count )
            
            if count! > 0 {
                //print("update")
                try db?.run( tbFilterChatTsFlag.update([ chattsflagTs <- data["ts"].stringValue ] ) )
                return true
                
            }else{
                //print("insert")
                try db?.run(tbChatTsFlag.insert( chattsflagFlag <- data["flag"].stringValue,
                                                 chattsflagTs <- data["ts"].stringValue ))
                return true
            }
            
        } catch {
            print("updateInertChatTsFlag Error:\(error)")
            return false
        }
    }
    
    
    func queryChatTsFlag(data:JSON) -> JSON {
        do {
            let query = tbChatTsFlag.filter( chattsflagFlag == data["flag"].stringValue)
            
            for row in try db!.prepare(query) {
                return JSON([ "flag": row[ chattsflagFlag],
                              "ts": row[ chattsflagTs] ])
            }
        } catch {
            print("queryChatTsFlag Error:\(error))")
        }
        return JSON([:])
    }
    
    
    func restDB(data:JSON) -> Bool {
        let tbs = data["db"].stringValue.components(separatedBy: "|")
        
        //"ChatHistory|Contacts|OpenRooms|ChatNews"
        do {
            for tb in tbs {
                switch tb.lowercased() {
                case "chathistory":
                    print("chathistory")
                    //try db.run( tbChatHistory.delete() )
                    try db?.run(tbChatHistory.delete())
                case "contacts":
                    print("contacts")
                    try db?.run( tbContacts.delete() )
                case "openrooms":
                    print("openrooms")
                    try db?.run( tbOpenRooms.delete() )
                case "chatnews":
                    print("chatnews")
                    try db?.run( tbChatNews.delete() )
                case "chattsflag":
                    try db?.run(tbChatTsFlag.delete() )
                default: break
                }
            }
            
            return true
        } catch {
            print("restDB Error:\(error)")
            return false
        }
    }
    
    func getDefaultContact(data:JSON) -> JSON {
        let action = data["action"].exists() ? data["action"].stringValue : ""
        
        let m_id = data["m_id"].exists() ? data["m_id"].stringValue : ""
        let custom_name = data["custom_name"].exists() ? data["custom_name"].stringValue : ""
        let addressbook = data["addressbook"].exists() ? data["addressbook"].stringValue : ""
        let sex = data["sex"].exists() ? data["sex"].stringValue : ""
        let birth = data["birth"].exists() ? data["birth"].stringValue : ""
        
        let email = data["email"].exists() ? data["email"].stringValue : ""
        let phone = data["phone"].exists() ? data["phone"].stringValue : ""
        let mobile = data["mobile"].exists() ? data["mobile"].stringValue : ""
        let grade = data["grade"].exists() ? data["grade"].stringValue : ""
        let corps = data["corps"].exists() ? data["corps"].intValue : 0
        
        let islock = data["islock"].exists() ? data["islock"].intValue : 0
        let isgroup = data["isgroup"].exists() ? data["isgroup"].intValue : 0
        let xgroup = data["xgroup"].exists() ? data["xgroup"].stringValue : ""
        let peonums = data["peonums"].exists() ? data["peonums"].intValue : 0
        let picture_path = data["picture_path"].exists() ? data["picture_path"].stringValue : ""
        
        let created_time = data["created_time"].exists() ? data["created_time"] : ""
        let updated_time = data["updated_time"].exists() ? data["updated_time"] : ""
        let contact_id = data["contact_id"].exists() ? data["contact_id"] : ""
        let contact_key = data["contact_key"].exists() ? data["contact_key"] : ""
        let status_msg = data["status_msg"].exists() ? data["status_msg"] : ""
        
        let ulast_updated_time = data["ulast_updated_time"].exists() ? data["ulast_updated_time"].stringValue:""
        let glast_updated_time = data["glast_updated_time"].exists() ? data["glast_updated_time"].stringValue:""
        let others = data["others"].exists() ? data["others"].stringValue : ""
        
        return JSON(["action":action,
                     "m_id":m_id,
                     "custom_name":custom_name,
                     "addressbook":addressbook,
                     "sex":sex,
                     "birth":birth,
                     "email":email,
                     "phone":phone,
                     "mobile":mobile,
                     "grade":grade,
                     "corps":corps,
                     "islock":islock,
                     "isgroup":isgroup,
                     "xgroup":xgroup,
                     "peonums":peonums,
                     "picture_path":picture_path,
                     "created_time":created_time,
                     "updated_time":updated_time,
                     "contact_id":contact_id,
                     "contact_key":contact_key,
                     "status_msg":status_msg,
                     "ulast_updated_time":ulast_updated_time,
                     "glast_updated_time":glast_updated_time,
                     "others":others])
    }
    
    
    func getDefaultChatHistory(data:JSON) -> JSON {
        let xsid = getOwner()["m_id"].stringValue
        let xcid = Utils.getCID(sid: xsid)
        
        let device = data["device"].exists() ? data["device"].stringValue : "mobile"
        var cid = data["cid"].exists() ? data["cid"].stringValue : xcid
        if cid.isEmpty { cid = xcid }
        
        let channel = data["channel"].exists() ? data["channel"].stringValue : ""
        let action = data["action"].exists() ? data["action"].stringValue : ""
        let sid = data["sid"].exists() ? data["sid"].stringValue : xsid
        
        let tid = data["tid"].exists() ? data["tid"].stringValue : ""
        let gid = data["gid"].exists() ? data["gid"].stringValue : ""
        let corps = data["coprs"].exists() ? data["corps"].intValue : 0
        let category = data["category"].exists() ? data["category"].stringValue : ""
        let xdata = data["data"].exists() ? data["data"].stringValue : ""
        
        let status = data["status"].exists() ? data["status"].intValue : 0
        let created_time = data["created_time"].exists() ? data["created_time"].stringValue : ""
        let updated_time = data["updated_time"].exists() ? data["updated_time"].stringValue : ""
        let location_name = data["location_name"].exists() ? data["location_name"].stringValue : ""
        let location_address = data["location_address"].exists() ? data["location_address"].stringValue : ""
        
        let location_phone = data["location_phone"].exists() ? data["location_phone"].stringValue : ""
        let location_latitude = data["location_latitude"].exists() ? data["location_latitude"].intValue : 0
        let location_longitude = data["longitude"].exists() ? data["longitude"].intValue : 0
        let flag = data["flag"].exists() ? data["flag"].intValue : 0
        
        return JSON( [ "device":device ,
                       "cid":cid,
                       "channel":channel,
                       "action":action,
                       "sid":sid,
                       "tid":tid,
                       "gid":gid,
                       "corps":corps,
                       "category":category,
                       "data":xdata,
                       "status":status,
                       "created_time":created_time,
                       "updated_time":updated_time,
                       "location_time":location_name,
                       "location_address":location_address,
                       "location_phone":location_phone,
                       "location_latitude":location_latitude,
                       "location_longitude":location_longitude,
                       "flag":flag] )
    }
    
    
    deinit {
        DBHelper.OWNER = JSON([:])
    }
}
