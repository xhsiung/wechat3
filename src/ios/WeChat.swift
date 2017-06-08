import Alamofire

@objc(WeChat) class WeChat : CDVPlugin , EBusDelegate {
    var ebus:EBusService?
    var dbhelper:DBHelper?
    var utils:Utils?
    static var roomName = ""
    var cmd:CDVInvokedUrlCommand?
    var firstConn = 0
    
    //init process
    override func pluginInitialize(){
        print("init pluginInitialize")
        dbhelper = DBHelper.getInstance()
        ebus = EBusService.getInstance()
        utils = Utils.getInstance()
        ebus!.delegate = self
        ebus!.dbhelper = dbhelper
        
        utils!.dbhelper = dbhelper
        utils!.ebus = ebus
    }
    
    //start
    @objc(start:)
    func start(_ command: CDVInvokedUrlCommand) {
        print("WeChat Start")
        self.cmd = command
    }
    
    //test
    @objc(test:)
    func test(_ command: CDVInvokedUrlCommand) {
        print("WeChat test")
        //_ = self.dbhelper?.queryGroupChatHistory()
        utils?.restContactsAdd()
        
    }
    
    //receive message
    func msgCallback(data: JSON) {
        print("msgCallback")
        DispatchQueue.global().async {
            //update
            self.commandDelegate!.evalJs("msgCallback(\(data))")
            
            //front readed write db
            if !WeChat.roomName.isEmpty{
                self.dbhelper!.updateInsertChatHistory(data:data,channel: WeChat.roomName ,status: 1)
            }
            
        }
    }
    
    
    func msgUnReadCallback(data: JSON) {
        print("msgUnReadCallback")
        DispatchQueue.global().async {
            self.commandDelegate!.evalJs("wechatOnUnReadChat(\(data))")
        }
        
    }
    
    
    func msgUnReadInitCallback(data: JSON) {
        print("msgUnReadInitCallback")
        DispatchQueue.global().async {
            self.commandDelegate!.evalJs("wechatOnUnReadChatInit(\(data))")
        }
    }
    
    
    //reconnected to connect
    func socketConnectCallback(){
        if firstConn > 0 {
            print("socketConnectCallback connect")
            self.initConn( self.cmd! )
        }
        firstConn += 1
    }
    
    //saveChatSettings
    @objc(saveChatSettings:)
    func saveChatSettings(_ command: CDVInvokedUrlCommand){
        print("WeChat saveChatSettings")
        let data = JSON(command.arguments[0])
        
        utils!.saveSettings(obj: data)
        
        //print( obj )
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK )
        self.commandDelegate!.send( pluginResult, callbackId: command.callbackId)
    }
    
    //getChatSettings
    @objc(getChatSettings:)
    func getChatSettings(_ command: CDVInvokedUrlCommand){
        print("WeChat getChatSettings")
        var jobj = utils!.getSettings()
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK , messageAs:jobj.dictionaryObject! )
        
        self.commandDelegate!.send( pluginResult, callbackId: command.callbackId)
    }
    
    
    //initConn
    @objc(initConn:)
    func initConn(_ command: CDVInvokedUrlCommand){
        print("WeChat initConn")
        let settings = UserDefaults.standard
        if settings.object(forKey: "serverip") == nil || settings.object(forKey: "port") == nil { return }
        self.connect(command)
        
        //init subscribe person and grpup
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(1000), execute: {
            let multichanns = self.utils!.getMultiChanns()
            self.ebus!.MultiSubscribe(data: multichanns )
            
            sleep(1)
            //signal online
            let signalpack = self.utils?.getSignalPack()
            self.ebus?.SendSignal(data: signalpack! )
            
            //cloud contacts add
             self.utils?.restContactsAdd()
            
            //unread updatedb
            let unreadpack = self.utils?.getUnreadPackJson()
            self.ebus?.exunread(data: unreadpack!)
            
        })
        
    }
    
    
    
    //connect
    @objc(connect:)
    func connect(_ command: CDVInvokedUrlCommand){
        print("WeChat connect")
        let jdata = utils!.getSettings()
        
        DispatchQueue.global().async {
            self.ebus!.Connect(data: jdata )
        }
        
    }
    
    @objc(disconnect:)
    func disconnect(_ command: CDVInvokedUrlCommand){
        DispatchQueue.global().async {
            self.ebus!.DisConnect()
        }
    }
    
    @objc(multiSubscribe:)
    func multiSubscribe(_ command: CDVInvokedUrlCommand){
        print("WeChat multisubscribe")
        let jdata = JSON(command.arguments[0])
        DispatchQueue.global().async {
            self.ebus!.MultiSubscribe(data: jdata)
        }
        
    }
    
    @objc(multiUnSubscribe:)
    func multiUnSubscribe(_ command: CDVInvokedUrlCommand){
        let jdata = JSON(command.arguments[0])
        DispatchQueue.global().async {
            self.ebus!.MultiUnSubscribe(data: jdata)
        }
        
    }
    
    @objc(send:)
    func send(_ command: CDVInvokedUrlCommand){
        var jdata = JSON(command.arguments[0])
        //undeliver
        if jdata["cid"].exists() {
            DispatchQueue.global().async {
                self.ebus!.Send(data: jdata)
            }
            
        }else {
            DispatchQueue.global().async {
                jdata = self.dbhelper!.getDefaultChatHistory(data: jdata)
                let _ = self.dbhelper!.insertChatHistory(data: jdata)
                self.ebus!.Send(data: jdata)
            }
        }
        
    }
    
    
    @objc(multiRegister:)
    func multiRegister(_ command: CDVInvokedUrlCommand){
        let jdata = JSON(command.arguments[0])
        
        DispatchQueue.global().async {
            let success = self.dbhelper!.operatorContacts(data: jdata)
            if !success {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR,messageAs: JSON(["success":false]).dictionaryObject!)
                
                self.commandDelegate!.send( pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    
    @objc(getOwner:)
    func getOwner(_ command: CDVInvokedUrlCommand){
        //let jdata = JSON(command.arguments[0])
        DispatchQueue.global().async {
            let jobj = self.dbhelper!.getOwner()
            let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
            
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    @objc(getContacts:)
    func getContacts(_ command: CDVInvokedUrlCommand){
        DispatchQueue.global().async {
            let jobj = self.dbhelper!.getContacts()
            let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    @objc(undelivered:)
    func undelivered(_ command: CDVInvokedUrlCommand){
        DispatchQueue.global().async {
            let jobj = self.dbhelper!.getChatHistoryUndeliverd()
            let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    @objc(querydbdate:)
    func querydbdate(_ command: CDVInvokedUrlCommand){
        let jdata = JSON(command.arguments[0])
        DispatchQueue.global().async {
            let jobj = self.dbhelper!.queryDBDate(data: jdata)
            let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    @objc(openrooms:)
    func openrooms(_ command: CDVInvokedUrlCommand){
        let jdata = JSON(command.arguments[0])
        let xaction = jdata["action"].stringValue
        let xchannel = jdata["channel"].stringValue
        
        DispatchQueue.global().async {
            let jobj = self.utils?.getOpenRoomPackJson(data: jdata)
            self.ebus?.OpenRooms(data: jobj!)
            
            //channel -->chathistory --> status:1
            if xaction == "open" {
                WeChat.roomName = xchannel
                _ = self.dbhelper?.updateChatHistoryStatus(action: "send", channel: xchannel , status: 1 )
                
            }else{
                WeChat.roomName = ""
            }
        }
    }
    
    
    @objc(getOpenRooms:)
    func getOpenRooms(_ command: CDVInvokedUrlCommand){
        var jdata = JSON(command.arguments[0])
        
        let sid = jdata["from"].stringValue
        let channel = jdata["channel"].stringValue
        let resturl = "\(utils!.getServerURL())/\(sid)/\(channel)"
        
        DispatchQueue.global().async {
            Alamofire.request( resturl ,headers:["Accept": "application/json"]).responseJSON { response in
                //debugPrint(response)
                var jobj = JSON(["data":[:] ])
                
                switch response.result {
                case .success(let value):
                    jobj = JSON(value)
                case .failure(let error):
                    print(error)
                }
                
                let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        }
        
    }
    
    
    @objc(getOnLineUsers:)
    func getOnLineUsers(_ command: CDVInvokedUrlCommand){
        var jdata = JSON(command.arguments[0])
        let resturl = "\(utils!.getServerURL())/xonlineusers"
        
        DispatchQueue.global().async {
            Alamofire.request(resturl , method:.post , parameters: jdata.dictionaryObject!,encoding: JSONEncoding.default).responseJSON { response in
                //debugPrint(response)
                var jobj = JSON(["data":[:] ])
                
                switch response.result {
                case .success(let value):
                    jobj = JSON(value)
                case .failure(let error):
                    print(error)
                }
                
                let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj.dictionaryObject!)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    
    @objc(crudNews:)
    func crudNews(_ command: CDVInvokedUrlCommand){
        var jdata = JSON(command.arguments[0])
        let action = jdata["action"].stringValue
        
        DispatchQueue.global().async {
            var pluginResult:CDVPluginResult
            switch action.lowercased() {
            case "insert":
                _ = self.dbhelper?.insertChatNews(data: jdata)
                
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: JSON(["success":true]).dictionaryObject! )
            case "query":
                let jobj = self.dbhelper?.queryChatNews(data: jdata)
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj!.dictionaryObject!)
                
            default:
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: JSON(["success":false]).dictionaryObject!)
                break
            }
            
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    
    @objc(crudTsFlag:)
    func crudTsFlag(_ command: CDVInvokedUrlCommand){
        var jdata = JSON(command.arguments[0])
        let action = jdata["action"].stringValue
        
        DispatchQueue.global().async {
            var pluginResult:CDVPluginResult
            
            switch action.lowercased() {
            case "insert","update":
                let isSuccess = self.dbhelper?.updateInertChatTsFlag(data: jdata)
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: JSON(["success":isSuccess]).dictionaryObject!)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                
            case "query":
                let jobj = self.dbhelper?.queryChatTsFlag(data: jdata)
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: jobj!.dictionaryObject!)
                
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                
            default:
                pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: JSON(["success":false]).dictionaryObject!)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                break
            }
            
        }
    }
    
    
    @objc(resetdb:)
    func resetdb(_ command: CDVInvokedUrlCommand){
        let jdata = JSON(command.arguments[0])
        DispatchQueue.global().async {
            var rjobj:JSON
            if self.dbhelper!.restDB(data: jdata) {
                rjobj = JSON(["success":true])
            }else{
                rjobj = JSON(["success":false])
            }
            
            let pluginResult = CDVPluginResult(status:CDVCommandStatus_OK,messageAs: rjobj.dictionaryObject!)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
        
    }
    
    
    @objc(clear:)
    func clear(_ command: CDVInvokedUrlCommand){
        //let jdata = JSON(command.arguments[0])
        DBHelper.OWNER = JSON([:])
        WeChat.roomName = ""
    }
    
    
    //echo
    @objc(echo:)
    func echo(command: CDVInvokedUrlCommand) {
        print("echo func")
        
        let obj = JSON(command.arguments[0])
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR,
                                           messageAs: JSON(["success":false]).dictionaryObject!)
        
        if ( obj.dictionaryObject!.count == 0){
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            //exit func
            return
        }
        
        //var jobj = JSON(["name":"alex","mobile": 12345 ,
        //              "data": [ ["id":1,"name":"one"],["id":2,"name":"two"] ]
        //            ])
        //var jobjdict = jobj.dictionaryObject!
        
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK,
                                       messageAs: obj.dictionaryObject! )
        
        self.commandDelegate!.send( pluginResult, callbackId: command.callbackId)
    }
    
    deinit {
        ebus = nil
        dbhelper = nil
        utils = nil
        WeChat.roomName = ""
    }
}
