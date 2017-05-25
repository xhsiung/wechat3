//
//  Utils.swift
//  App
//
//  Created by Pan Alex on 2017/5/17.
//  Copyright © 2017年 Pan Alex. All rights reserved.
//

import Foundation
import Alamofire

class Utils {
    static var utils:Utils?
    var dbhelper:DBHelper?
    var ebus:EBusService?
    
    static func getInstance() -> Utils{
        if utils == nil {
            utils = Utils()
        }
        return utils!
    }
    
    static func getInviteChann(sid:String,tid:String) -> String {
        let max = (sid > tid) ? sid : tid
        let min = (sid < tid) ? sid : tid
        return "\(max)@\(min)"
    }
    
    static func getCID(sid:String) -> String{
        let ts = Utils.getNowTimeStamp()
        return "\(sid)\(ts)"
    }
    
    //get date time()
    static func getNowTimeStamp() -> String {
        let ts = Int64( NSDate().timeIntervalSince1970 * 1000)
        return "\(ts)"
    }
    
    func getMultiChanns() -> JSON {
        let owner = dbhelper?.getOwner()
        if (owner == nil) {return JSON([:])}
        
        var contactsDB = dbhelper!.getContacts()
        
        var jsonArr = [JSON]()
        jsonArr.append( JSON( ["channel": owner!["m_id"].stringValue , "device":"mobile"] )  )
        
        for user in ( contactsDB["data"].array)! {
            //ignore owner
            if user["corps"] == -1 { continue }
            
            //personal
            if user["isgroup"] == 0 {
                let inviteChann = Utils.getInviteChann(sid: owner!["m_id"].stringValue, tid: user["m_id"].stringValue)
                jsonArr.append( JSON(["channel": inviteChann,"device":"mobile"]) )
                
                //group
            }else if user["isgroup"] == 1 {
                jsonArr.append( JSON(["channel": user["channel"].stringValue,"device":"mobile"]) )
            }
        }
        
        return JSON(["multichanns": jsonArr ])
    }
    
    
    func getUnreadPackJson() -> JSON {
        let owner = dbhelper?.getOwner()
        if (owner == nil) {return JSON([:])}
        
        let xlastChatHistoryRow = dbhelper?.getChatHistoryLastRow()
        var updatedTime = ""
        
        print( "getUnreadPackJson" )
        var channsarr = [String]()
        for row in (dbhelper?.getContactsGroup())! {
            channsarr.append( row["m_id"].stringValue)
        }
        
        updatedTime = ( xlastChatHistoryRow!.dictionary!.count == 0) ? owner!["updated_time"].stringValue : xlastChatHistoryRow!["updated_time"].stringValue
        
        let pack = JSON([ "sid": owner!["m_id"].stringValue,
               "channels": JSON( channsarr ),
               "last_updated_time": updatedTime ])
 
        //print( pack )
        return pack
    }
    
    
    func getOpenRoomPackJson(data:JSON) -> JSON {
        let owner = dbhelper?.getOwner()
        if (owner == nil) {return JSON([:])}
        
        let sid = owner!["m_id"].stringValue
        let action = data["action"].stringValue
        let channel = data["channel"].stringValue
        
        return JSON([ "sid":sid , "action":action , "channel":channel])
    }
    
    
    func getSignalPack() -> JSON {
        let owner = dbhelper?.getOwner()
        if (owner == nil) {return JSON([:])}
        
        let sid = owner!["m_id"].stringValue
        let name = owner!["cumstom_name"].stringValue
        let address = owner!["addressbook"].stringValue
        return JSON([ "sid":sid , "name":name , "address":address , "wechat": true])
    }
    
    
    func getServerURL() -> String {
        let settings = getSettings()
        return "http://\(settings["serverip"].stringValue):\(settings["port"].intValue)"
    }
    
    func saveSettings(obj:JSON) -> Void {
        let userDefault = UserDefaults.standard
        userDefault.set( (obj["serverip"].exists() ? obj["serverip"].stringValue : nil), forKey: "serverip")
        userDefault.set( obj["port"].exists() ? obj["port"].intValue : nil, forKey: "port")
        
        userDefault.set( obj["notifyTarget"].exists() ? obj["notifyTarget"].stringValue:"", forKey: "notifyTarget")
        userDefault.set( obj["hasNotify"].exists() ? obj["hasNotify"].int64:0, forKey: "hasNotify")
        userDefault.set( obj["senotifyTitlerverip"].exists() ? obj["notifyTitle"].stringValue:"", forKey: "notifyTitle")
        userDefault.set( obj["notifyTicker"].exists() ? obj["notifyTicker"].stringValue:"", forKey: "notifyTicker")
        userDefault.set( obj["hasVibrate"].exists() ? obj["hasVibrate"].intValue:0, forKey: "hasVibrate")
        userDefault.set( obj["hasSound"].exists() ? obj["hasSound"].intValue:0, forKey: "hasSound")
        userDefault.set( obj["hasSaveEl"].exists() ? obj["hasSaveEl"].intValue:0, forKey: "hasSaveEl")
        userDefault.set( obj["key"].exists() ? obj["key"].stringValue:"", forKey: "key")
        userDefault.set( obj["fontSize"].exists() ? obj["fontSize"].stringValue:"", forKey: "fontSize")
    }
    
    
    func getSettings()->JSON {
        let userDefault = UserDefaults.standard
        if userDefault.object(forKey: "serverip") == nil || userDefault.object(forKey: "port") == nil {
            return JSON([:])
        }
        
        let serverip = userDefault.object(forKey: "serverip") as! String
        let port = userDefault.object(forKey: "port") as! Int64
        
        let notifyTarget = userDefault.object(forKey: "notifyTarget") as! String
        let hasNotify = userDefault.object(forKey: "hasNotify") as! Int64
        let notifyTitle = userDefault.object(forKey: "notifyTitle") as! String
        let notifyTicker = userDefault.object(forKey: "notifyTicker") as! String
        let hasVibrate = userDefault.object(forKey: "hasVibrate") as! Int64
        let hasSound = userDefault.object(forKey: "hasSound") as! Int64
        let hasSaveEl = userDefault.object(forKey: "hasSaveEl") as! Int64
        let key = userDefault.object(forKey: "key") as! String
        let fontSize = userDefault.object(forKey: "fontSize") as! String
        
        return JSON(["serverip":serverip,
                     "port":port,
                     "notifyTarget":notifyTarget,
                     "hasNotify":hasNotify,
                     "notifyTitle":notifyTitle,
                     "notifyTicker":notifyTicker,
                     "hasVibrate":hasVibrate,
                     "hasSound":hasSound,
                     "hasSaveEl":hasSaveEl,
                     "key":key,
                     "fontSize":fontSize])
    }
}
