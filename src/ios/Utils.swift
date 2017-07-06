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
                jsonArr.append( JSON(["channel": user["m_id"].stringValue,"device":"mobile"]) )
            }
        }
        
        return JSON(["multichanns": jsonArr ])
    }
    
    
    func getContactsPackJson() -> JSON {
        let owner = dbhelper?.getOwner()
        
        let app = UIApplication.shared.delegate as! AppDelegate
        var groupArr = [String]()
        for row in (dbhelper?.getContactsGroup())! {
            groupArr.append( row["m_id"].stringValue)
        }
    
        let m_id = owner!["m_id"].stringValue
        let custom_name = owner!["custom_name"].stringValue
        let addressbook = owner!["addressbook"].stringValue
        let sex = owner!["sex"].stringValue
        let birth = owner!["birth"].stringValue
        
        let email = owner!["email"].stringValue
        let phone = owner!["phone"].stringValue
        let mobile = owner!["mobile"].stringValue
        let grade = owner!["grade"].stringValue
        let corps = owner!["corps"].stringValue
        
        let islock = owner!["islock"].intValue
        let isgroup = owner!["isgroup"].intValue
        let xgroup = groupArr.joined(separator: ",")
        let peonums = owner!["peonums"].intValue
        let picture_path = owner!["picture_path"].stringValue
        
        let created_time = owner!["created_time"].stringValue
        let updated_time = owner!["updated_time"].stringValue
        let contact_id = owner!["contact_id"].stringValue
        let contact_key = owner!["contact_key"].stringValue
        let status_msg = owner!["status_msg"].stringValue
        
        let ulast_updated_time = owner!["ulast_updated_time"].stringValue
        let glast_updated_time = owner!["glast_updated_time"].stringValue
        let others = owner!["others"].stringValue
        let token = app.token
        
        return JSON( ["m_id": m_id,
                      "custom_name": custom_name,
                      "addressbook": addressbook,
                      "sex": sex,
                      "birth": birth,
                      
                      "email": email,
                      "phone": phone,
                      "mobile": mobile,
                      "grade": grade,
                      "corps": corps,
            
                      "islock": islock,
                      "isgroup": isgroup,
                      "xgroup": xgroup,
                      "peonums": peonums,
                      "picture_path": picture_path,
            
                      "created_time": created_time,
                      "updated_time": updated_time,
                      "contact_id": contact_id,
                      "contact_key": contact_key,
                      "status_msg": status_msg,
                      
                      "ulast_updated_time":ulast_updated_time,
                      "glast_updated_time":glast_updated_time,
                      "others":others,
                      "unread": 0,
                      "platform": "ios",
                      "token": token
                      ])

    }

    
    func getUnreadPackJson() -> JSON {
        let owner = dbhelper?.getOwner()
        
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
        
        let sid = owner!["m_id"].stringValue
        let action = data["action"].stringValue
        let channel = data["channel"].stringValue
        
        return JSON([ "sid":sid , "action":action , "channel":channel])
    }
    
    
    func getSignalPack() -> JSON {
        let owner = dbhelper?.getOwner()
        
        let sid = owner!["m_id"].stringValue
        let name = owner!["cumstom_name"].stringValue
        let address = owner!["addressbook"].stringValue
        return JSON([ "sid":sid , "name":name , "address":address , "wechat": true])
    }
    
    
    func getServerURL() -> String {
        let settings = getSettings()
        return "http://\(settings["serverip"].stringValue):\(settings["port"].intValue)"
    }
    
    
    func restContactsAdd() {
        let jsonPack = getContactsPackJson()
        let resturl = "\(getServerURL())/contacts/add"
        DispatchQueue.global().async {
            Alamofire.request( resturl,method:.post
                ,parameters:jsonPack.dictionary! ,headers:["Accept": "application/json"]).responseJSON { response in
                //debugPrint(response)
                //var jobj = JSON(["data":[:] ])
                switch response.result {
                case .success(let value):
                    let _ = JSON(value)
                    print("restContactsAdd scucess")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func saveSettings(obj:JSON) -> Void {
        let userDefault = UserDefaults.standard

        userDefault.set( obj["serverip"].exists() ? obj["serverip"].stringValue : "wechat.bais.com.tw", forKey: "serverip")
        userDefault.set( obj["port"].exists() ? obj["port"].intValue : 3002, forKey: "port")
        
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
