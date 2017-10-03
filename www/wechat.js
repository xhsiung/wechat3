cordova.define("cordova-plugins-wechat.wechat", function(require, exports, module) {
   var WeChat = function(){
   var self = this;
               
   self.channels = {
        wechatevent :cordova.addWindowEventHandler("wechatevent")
   };
   
        //rigister Event
        self.channels["wechatevent"].onHasSubscribersChange = WeChat.onHasSubscribersChangeStart;
   }
   
   //listen  deviceready auto start
   WeChat.onHasSubscribersChangeStart = function() {
        console.log("onHasSubscribersChangeStart");
        cordova.exec(wechat._status, wechat._error, "WeChat" , "start" , [] ) ;
   };
   
   WeChat.prototype._status = function(info){
        console.log("_status");
        //emit Event
        fireWindowEvent("wechatevent", info);
   };
   
   WeChat.prototype._error = function(e) {
        console.log("_error");
        console.log("Error initializing WeChat: " + e);
   };
   
   
   WeChat.prototype.echo = function( arg0 , success , error){
        cordova.exec(success, error, 'WeChat', 'echo', [arg0]);
   }
   
   WeChat.prototype.echojs = function( arg0 , success , error){
        if (arg0 && typeof(arg0) === 'string' && arg0.length > 0) {
            success(arg0);
        } else {
            error('Empty message!');
        }
   }
   
   WeChat.prototype.saveChatSettings = function(arg0, errorCallback){
        cordova.exec(null, errorCallback, 'WeChat', 'saveChatSettings', [arg0]);
   }
   
   WeChat.prototype.getChatSettings = function(successCallback){
        cordova.exec( successCallback , null , "WeChat", "getChatSettings" , []);
   }
   
   //connect
   WeChat.prototype.connect = function(){
        cordova.exec( null , null , "WeChat", "connect" , []);
   }
   
   //disconnect
   WeChat.prototype.disconnect = function(){
        cordova.exec( null , null , "WeChat", "disconnect" , []);
   }
   
   //subscribe
   WeChat.prototype.multiSubscribe = function(arg0){
        var arrChann = [] ;
        for (var i=0;i < arg0.multichanns.length ; i++){
            arrChann.push({"channel":arg0.multichanns[i].channel ,"device":"mobile"})
        }
        var pack = { multichanns : arrChann };
        cordova.exec( null , null , "WeChat", "multiSubscribe" , [pack]);
   }
   
   //unsubscribe
   WeChat.prototype.multiUnSubscribe = function(arg0){
        cordova.exec( null , null , "WeChat", "multiUnSubscribe" , [arg0]);
   }
   
   //send
   WeChat.prototype.send = function(arg0){
        cordova.exec( null , null , "WeChat", "send" , [arg0]);
   }
   
   //multiRegister
   WeChat.prototype.multiRegister = function(arg0, successCallback ){
        cordova.exec( successCallback , null , "WeChat", "multiRegister" , [arg0]);
   }
   
   //getOwner
   WeChat.prototype.getOwner = function(successCallback){
        cordova.exec( successCallback , null , "WeChat", "getOwner" , []);
   }
            
    //existOwner
    WeChat.prototype.existOwner = function(successCallback){
        this.getOwner( function(data){
            if (typeof data["m_id"] === "undefined") {
                      successCallback(false) ;
            }else{
                      successCallback(true) ;
            }
        });
    }
               
   
   //getContatcts
   WeChat.prototype.getContacts = function(successCallback){
        cordova.exec( successCallback , null , "WeChat", "getContacts" , []);
   }
   
   //initConn
   WeChat.prototype.initConn = function(){
        cordova.exec( null , null , "WeChat", "initConn", []);
        WeChat.count++;
   }
               
   //undelivered
   WeChat.prototype.undelivered = function(successCallback){
        cordova.exec( successCallback , null , "WeChat", "undelivered" , []);
   }
   
   //querydbdate
   WeChat.prototype.querydbdate = function(arg0, successCallback){
        cordova.exec( successCallback , null , "WeChat", "querydbdate" , [arg0]);
   }
   
   //openrooms
   WeChat.prototype.openrooms = function(arg0){
        cordova.exec( null , null , "WeChat", "openrooms" , [arg0]);
   }
   
   //getOpenRooms
   WeChat.prototype.getOpenRooms = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "getOpenRooms" , [ arg0 ]);
   }
   
   //getOpenRooms
   WeChat.prototype.getOnLineUsers = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "getOnLineUsers" , [ arg0 ]);
   }
   
   //crudNews
   WeChat.prototype.crudNews = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "crudNews" , [ arg0 ]);
   }
   
   //crudTsFlag
   WeChat.prototype.crudTsFlag = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "crudTsFlag" , [ arg0 ]);
   }
   
   //resetdb
   WeChat.prototype.resetdb = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "resetdb" , [ arg0 ]);
   }
   
   //clear
   WeChat.prototype.clear = function(){
        cordova.exec( null , null , "WeChat", "clear" , [ ]);
   }
   
   //del chat_history table
   WeChat.prototype.del_chat_history = function( arg0 , successCallback){
        cordova.exec( successCallback , null , "WeChat", "del_chat_history" , [ arg0 ]);
   }
               
   //getInviteChann
   WeChat.prototype.getInviteChann = function( sid , tid){
        var max = ( sid > tid) ?  sid : tid;
        var min = ( sid < tid) ?  sid : tid;
        return max + "@" + min ;
   }
               
   //test
   WeChat.prototype.test = function(){
        cordova.exec( null , null , "WeChat", "test" , [ ]);
   }
   
   module.exports = new WeChat();


});
