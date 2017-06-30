//
//  EBusService.swift
//  TestSocketIO
//
//  Created by Pan Alex on 2017/5/10.
//  Copyright © 2017年 Pan Alex. All rights reserved.
//
import Foundation
import SocketIO

//import SwiftyJSON
class EBusService : NSObject{
    static var ebus:EBusService?
    //WeChat.swift setted
    var dbhelper:DBHelper?
    var socket:SocketIOClient?
    var delegate: EBusDelegate?
    
    var lastMsgCid = ""
    
    static func getInstance() -> EBusService{
        if ebus == nil {
            ebus =  EBusService()
        }
        return ebus!
    }
    
    override init(){
        super.init()
    }
    
    func Connect(data:JSON) -> Void {
        if data["serverip"].stringValue == "" || data["port"].intValue == 0 {
            print("Connect error")
            return
        }
        
        if socket == nil {
            let serverip = data["serverip"].stringValue
            let port = data["port"].intValue
            let url = URL(string: "http://\(serverip):\(port)")
            
            //socket = SocketIOClient(socketURL: url!, config: [.log(true), .forcePolling(true)])
            socket = SocketIOClient(socketURL: url!, config: [ .forcePolling(true)])
            addHandlers()
            socket?.connect()
        }
    }
    
    func Connect() -> Void {
        let userDefault = UserDefaults.standard
        let serverip = userDefault.object(forKey: "serverip")
        let port = userDefault.object(forKey: "port")
        
        if userDefault.object(forKey: "serverip") == nil || userDefault.object(forKey: "port") == nil {
            return
        }
        
        if socket == nil {
            let url = URL(string: "http://\(serverip):\(port)")
            //socket = SocketIOClient(socketURL: url!, config: [.log(true), .forcePolling(true)])
            socket = SocketIOClient(socketURL: url!, config: [ .forcePolling(true)])
            addHandlers()
            socket?.connect()
        }
        
    }
    
    func DisConnect() -> Void {
        //if socket?.status == SocketIOClientStatus.connected{
            socket?.disconnect()
            socket = nil
        //}
    }
    
    //data array obj
    func MultiSubscribe(data:JSON) -> Void{
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("multisubscribe", with: [ data.rawString()! ])
        }
        
    }
    
    //data array obj
    func MultiUnSubscribe(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("multiunsubscribe", with: [ data.rawString()!])
        }
    }
    
    //data obj
    func Send(data:JSON) -> Void{
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("send", with: [ data.rawString()! ])
            print(data.rawString()!)
        }
    }
    
    func exunread(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("exunread", with: [ data.rawString()!])
        }
    }
    
    func OpenRooms(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("openrooms", with: [ data.rawString()!])
        }
    }
    
    func SendSignal(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("signal", with: [ data.rawString()!])
        }
    }
    
    //add handler
    func addHandlers(){
        socket?.on(clientEvent: .connect, callback: { (data, ack) in
            print("conenct")
            self.delegate?.socketConnectCallback()
        })
        
        socket?.on(clientEvent: .disconnect, callback: { (data, ack) in
            print("disconnect")
        })
        
        socket?.on(clientEvent: .error, callback: { (data, ack) in
            print("error")
        })
        
        socket?.on(clientEvent: .reconnect, callback: { (data, ack) in
            print("reconnect")
        })
        
        
        socket?.on("mqmsg", callback: { ( data, ack) in
            print("got msg")
            let xdata = data[0] as! String
            
            if let jsonStr = xdata.data(using: .utf8, allowLossyConversion: false) {
                do{
                    let obj = try JSON(data: jsonStr)
                    let cid = obj["cid"].stringValue
                    let device = obj["device"].stringValue
                    let sid = obj["sid"].stringValue
                    let owner = self.dbhelper!.getOwner()["m_id"].stringValue
                    let action = obj["action"].stringValue
                    let channel = obj["channel"].stringValue
                    
                    
                    if cid == self.lastMsgCid || !device.contains("mobile") { return }
                    self.lastMsgCid = cid
                    
                    var jarr = [JSON]()
                    jarr.append( obj )
                    let jobjArr = JSON(["data": jarr] )
                    
                    
                    //accept contacts recieve
                    if ( self.dbhelper!.hasContacts(m_id: sid)){
                        print("in contacts list--------------->")
                        
                        /**
                         owner:"send" ,reciever:"send|notify" , other:"invite"
                         */
                        
                        if ( owner == sid && action == "send"){    //owner accept action:send
                            self.dbhelper!.updateInsertChatHistory(data:jobjArr,channel: channel , status: 0)
                            self.actionSendTask(data: jobjArr)
                            
                        }else{
                            switch action {
                            case "send":
                                self.dbhelper!.updateInsertChatHistory(data:jobjArr,channel: channel , status: 0)
                                self.actionSendTask(data: jobjArr)
                                
                            case "notify":
                                self.dbhelper!.updateInsertChatHistory(data:jobjArr,channel: channel , status: 1)
                                self.actionNotifyTask(data: jobjArr)
                                
                            default: break
                            }
                        }
                        
                    }else{
                        //accept invite
                        print("not in contacts list---------------->")
                        if action == "invite" {
                            self.dbhelper!.updateInsertChatHistory(data:jobjArr,channel: channel,status:1)
                            self.actionInviteTask(data: jobjArr)
                        }
                    }
                    
                }catch{
                    print("EBusService exunreaded mqmsg fail:\(error)")
                }
            }
            
        })
        
        
        socket?.on("exunreaded", callback: { (data, ack) in
            print("got exunreaded")
            let xdata = data[0] as! String
            
            if let jsonStr = xdata.data(using: .utf8, allowLossyConversion: false) {
                do{
                    let obj = try JSON(data: jsonStr)
                    
                    //true has rows
                    if self.dbhelper!.hasChatHistoryLastRow {
                        self.dbhelper?.updateInsertChatHistory(data: obj, action: "send|notify|invite", status: 0)
                        
                        //throw unread rows
                        let jobj = self.dbhelper?.queryUnreadChatHistory(action: "send")
                        self.delegate?.msgUnReadCallback(data: jobj!)
                        
                        //false no rows --> init
                    }else{
                        self.dbhelper?.updateInsertChatHistory(data: obj, action: "send|notify|invite", status: 1)
                    }
                    
                    //triger
                    let jobj = self.dbhelper?.queryGroupChatHistory()
                    self.delegate?.msgUnReadInitCallback(data: jobj!)
                    
                    print("exunreaded update db")
                }catch{
                    print("EBusService exunreaded Error:\(error)")
                }
                
            }
            
        })
        
        socket?.on("openroomsed", callback: { (data, ack) in
            print("openroomsed")
            
        })
        
        socket?.on("asked", callback: { (data, ack) in
            print("asked")
        })
        
        socket?.on(clientEvent: .statusChange, callback: { (data, ack) in
            print("statusChange")
        })
    }
    
    //remove handler
    func removeHandler() -> Void{
        socket?.off("connect")
        socket?.off("disconnect")
        socket?.off("error")
        socket?.off("reconnect")
        socket?.off("mqmsg")
        socket?.off("unreaded")
        socket?.off("exunreaded")
        socket?.off("asked")
        socket?.off("openroomsed")
    }
    
    //send task
    func actionSendTask(data:JSON) {
        print("actionSendTask")
        
        //queryUnRead rows {data:[]}
        let jdata = dbhelper!.queryUnreadChatHistory(action: "send")
        
        //send front
        delegate!.msgCallback(data: jdata)
    }
    
    
    func actionInviteTask(data:JSON){
        print("actionInviteTask")
    }
    
    func actionNotifyTask(data:JSON) {
        print("actionNotifyTask")
    }
    
    
    deinit {
        removeHandler()
        EBusService.ebus = nil
        dbhelper = nil
        socket = nil
        delegate = nil
    }
}
