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
    var utils:Utils?
    
    var ispass = true
    
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
            let xhttp = data["protocol"].stringValue
            
            var url = URL(string:"");
            
            if  xhttp == "http" {
                url = URL(string: "http://\(serverip):\(port)")
            }
            
            if  xhttp == "https" {
                url = URL(string: "https://\(serverip)")
            }
            
            //socket = SocketIOClient(socketURL: url!, config: [.log(true), .forcePolling(true)])
            socket = SocketIOClient(socketURL: url!, config: [ .forcePolling(true),.forceNew(true)])
            addHandlers()
            socket?.connect()
        }
    }
    
    func Connect() -> Void {
        Connect(data: (utils?.getSettings())!  );
    }
    
    func DisConnect() -> Void {
        //if socket?.status == SocketIOClientStatus.connected{
            socket?.disconnect()
            socket = nil
        //}
        print("EBusService DisConnect")
    }
    
    //data array obj
    func MultiSubscribe(data:JSON) -> Void{
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("multisubscribe", with: [ data.rawString()! ])
        }
        print("EBusService MultiSubscribe")
    }
    
    //data array obj
    func MultiUnSubscribe(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("multiunsubscribe", with: [ data.rawString()!])
        }
        print("EBusService MultiUnSubscribe")
    }
    
    //data obj
    func Send(data:JSON) -> Void{
        if socket?.status == SocketIOClientStatus.connected {
            
            socket?.emit("send", with: [ data.rawString()! ])
            print(data.rawString()!)
        }
        print("EBusService Send")
    }
    
    func exunread(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("exunread", with: [ data.rawString()!])
        }
        print("EBusService exunread")
    }
    
    func OpenRooms(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("openrooms", with: [ data.rawString()!])
        }
        print("EBusService OpenRooms")
    }
    
    func SendSignal(data:JSON) -> Void {
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit("signal", with: [ data.rawString()!])
        }
        print("EBusService SendSignal")
    }
    
    //add handler
    func addHandlers(){

        socket?.on(clientEvent: .connect, callback: { (data, ack) in
            print("EBusService Handlers conenct")
        })
        
        socket?.on(clientEvent: .disconnect, callback: { (data, ack) in
            print("EBusService Handlers disconnect")
        })
        
        socket?.on(clientEvent: .error, callback: { (data, ack) in
            print("EBusService Handlers error")
        })
        
        socket?.on(clientEvent: .reconnect, callback: { (data, ack) in
            print("EBusService Handlers reconnect")
            //self.delegate?.socketReconnect()
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                let multichanns = self.utils!.getMultiChanns()
                self.MultiSubscribe(data: multichanns )
		
		let signalpack = self.utils?.getSignalPack()
                self.SendSignal(data: signalpack! )
            })
        })
        
        
        socket?.on("mqmsg", callback: { ( data, ack) in
            print("got msg")
            let xdata = data[0] as! String
            
            print( xdata )
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
            print("EBuseSErvice Event openroomsed")
            
        })
        
        socket?.on("asked", callback: { (data, ack) in
            print("EBuseSErvice Event asked")
        })
        
        socket?.on(clientEvent: .statusChange, callback: { (data, ack) in
            print("EBuseSErvice Event statusChange")
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
        print("EBuseSErvice actionInviteTask")
    }
    
    func actionNotifyTask(data:JSON) {
        print("EBuseSErvice actionNotifyTask")
    }
    
    deinit {
        removeHandler()
        EBusService.ebus = nil
        dbhelper = nil
        socket = nil
        delegate = nil
    }
}
