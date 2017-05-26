# WeChat Project

WeChat Project objectives is intergrated  communication for android .

## Structure 
![image](https://raw.githubusercontent.com/xhsiung/wechat2/master/imgs/flow.png)

## Show
![image](https://raw.githubusercontent.com/xhsiung/wechat2/master/imgs/show.png)

## Installation
```install
sudo gem install cocoapods
cordova create myapp
cd myapp
cordova platform add ios
cordova plugin add https://github.com/xhsiung/wechat3.git
cd platform/ios
pod install
```

Server
```server
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
echo "deb http://axsoho.com/debs/tos tosdev main contrib non-free" | sudo tee -a /etc/apt/sources.list.d/axsoho.list

sudo apt-get update 
sudo apt-get install node
sudo apt-get install mongodb-org
```

## Usage

connect  server initConn
```initConnect
wechat.initConn();
```

connect server
```
wechat.connect();
```

disconnect server
```
wechat.disconnect();
```

subscribe  
```
wechat.multiSubscribe();
```

unsubscribe  
```
wechat.multiUnSubscribe();
```

send
```
wechat.send();
```

querydbdate
```
wechat.querydbdate();
```

multiRegister
```
wechat.multiRegister(args,errorCallback)
```

getContacts
```
wechat.getContacts(successCallback,errorCallback)
```

undelivered
```
wechat.undelivered(successCallbcak)
```

openrooms
```
wechat.openrooms(args,function(successCallbcak){})
```

getOpenRooms
```
wechat.getOpenRooms(args,function(successCallbcak){})
```

getOnLineUsers
```
wechat.getOnLineUsers(args,function(successCallbcak){})
```

crudNews
```
wechat.crudNews(args,function(successCallbcak){})
```

crudTsFlag
```
wechat.crudTsFlag(args,function(successCallbcak){})
```

resetdb
```
wechat.resetdb(function(errorCallbcak){})
```

wechatOnInviteRecived
```
function wechatOnInviteRecived( obj ){}
```

wechatOnUnReadChat
```
function wechatOnUnReadChat( obj ){}
```

wechatOnUnReadChatInit
```
function wechatOnUnReadChatInit( obj ){}
```

 
Sample
```
<!DOCTYPE html>

<html>
<head>
    <meta http-equiv="Content-Security-Policy" content="default-src 'self' data: gap: https://ssl.gstatic.com 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; media-src *; img-src 'self' data: content:;">
    <meta name="format-detection" content="telephone=no">
    <meta name="msapplication-tap-highlight" content="no">
    <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width">
    <title>Hello World</title>
  
</head>
<body>
    
<div class="app">
    <div id="deviceready" class="blink">
        <p class="event listening">Connecting to Device</p>
        <p class="event received">Device is Ready</p>
    </div>
</div>


<button type="button" onclick="multiRegister()" >multiRegister</button>
<button type="button" onclick="getOwner()">getOwner</button>
<button type="button" onclick="getContacts()">getContacts</button>

<button type="button" onclick="saveChatSettings()">saveChatSettings</button>
<button type="button" onclick="getChatSettings()">getChatSettings</button>
<button type="button" onclick="initConn()">initConn</button>
<button type="button" onclick="connect()">connect</button>
<button type="button" onclick="disconnect()">disconnect</button>


<hr>
tid:<input type="text" id="xtid"  value="u0002">
channel:<input type="text" id="xchannel" value="u0002@u0001">
data:<input type="text" id="xmsg" value="mymessage">
<hr>

<button type="button" onclick="multiSubscribe()">multiSubscribe</button>
<button type="button" onclick="multiUnSubscribe()">multiUnSubscribe</button>

<button type="button" onclick="openrooms()" >openrooms</button>
<button type="button" onclick="closerooms()" >closerooms</button>
<button type="button" onclick="getOpenRooms()" >getOpenRooms</button>

<button type="button" onclick="send()">send</button>
<button type="button" onclick="sendGroup()">sendGroup</button>
<button type="button" onclick="undelivered()">undelivered</button>
<button type="button" onclick="querydbdate()">querydbdate</button>

<button type="button" onclick="getOnLineUsers()" >getOnLineUsers</button>
<button type="button" onclick="crudTsFlag()" >crudTsFlag</button>
<button type="button" onclick="crudNews()" >crudNews</button>
<button type="button" onclick="resetdb()" >resetdb</button>

<button type="button" onclick="myclear()">myclear</button>

<div id="message"></div>
    
<script type="text/javascript" src="js/jquery.min.js"></script>
<script type="text/javascript" src="cordova.js"></script>
<script type="text/javascript" src="js/index.js"></script>
<script type="text/javascript">
    document.addEventListener("deviceready", onDeviceReady, false);
    function onDeviceReady() {
        window.addEventListener("wechatevent", OnEBusEvent, false);
    };
    
    function OnEBusEvent( obj ){  //JSONObject
        console.log("OnEBusEvent");
    };
    function msgCallback(obj){
        console.log(obj);
        for (var i=0; i < obj.data.length; i++){
            $("#message").append("<p>" + obj.data[i].data + "</p>");
        }
    }
    //unreaded
    function wechatOnUnReadChat(obj){
        //console.log( obj  )
        for (var i=0; i< obj.data.length ; i++){
            console.log(obj.data[i])
        }
    }
    // only one shoot
    function wechatOnUnReadChatInit( obj ){
        //console.log( obj  )
        for (var i=0; i< obj.data.length ; i++){
            console.log(obj.data[i])
        }
    }
    function saveChatSettings(){
        var conf = { serverip: "",
            port: 0,
            notifyTarget: "",
            hasNotify: 1,
            notifyTitle: "",
            notifyTicker: "",
            hasVibrate: 0,
            hasSound: 0,
            hasSaveEl: 1 ,
            key: "1234567890mobile" ,
            fontSize: 16
        };
    
        wechat.saveChatSettings( conf , function(err){
            alert("error");
        });
    }
    //getChatSettings
    function getChatSettings(){
        wechat.getChatSettings( function( data ){
            console.log( data );
        });
    }
    function initConn(){
        wechat.initConn()
    }
    //connect
    function connect(){
        wechat.connect();
    }
    //disconnect
    function disconnect(){
        wechat.disconnect();
    }
    //multiSubscribe
    function multiSubscribe(){
        var pack = {multichanns:[{channel:"u0002@u0001"},
                                 {channel:"u0003@u0002"},
                                 {channel:$("#xchannel").val() }]};
            wechat.multiSubscribe(pack);
    }
        
    function multiUnSubscribe(){
        var pack = {multichanns:[{channel:"u0002@u0001"},
                                 {channel:"u0003@u0002"},
                                 {channel:$("#xchannel").val() }]};
        wechat.multiUnSubscribe(pack);
    }
    
    function send(){
        var pack = {channel:"u0002@u0001",
                    device:"desktop|mobile",
                    action:"send",
                    tid:$("#xtid").val(),
                    data: $("#xmsg").val() };
        wechat.send(pack);
    }
    function sendGroup(){
        var pack = {device:"desktop|mobile",
                    channel: $("#xchannel").val(),
                    tid: $("#xtid").val(),
                    gid:$("#xchannel").val(),
                    action:"send",
                    category:"user",
                    data: $("#xmsg").val() };
        wechat.send(pack);
    }
    function multiRegister(){
         //only action:"insert|update|delete|deleteall"
         var obj = { action:"deleteall"}
         
         var obj2 = { action: "insert",m_id: "u0001",
                    custom_name:"alex02", corps: -1, updated_time:"1495430981548"} ;
         
         var obj3 = { action: "insert" ,m_id: "u0002", custom_name:"alex03"} ;
         
         var obj4 = { action: "insert" ,m_id: "u0003", custom_name:"alex04" } ;
         
         //group
         var obj5 = { action: "insert" ,m_id: "g0001",isgroup: 1, custom_name:"mygroup01"} ;
         var obj6 = { action: "insert" ,m_id: "g0002",isgroup: 1, custom_name:"mygroup02" } ;
         
         var pack = [ obj , obj2 , obj3 , obj4, obj5, obj6] ;
         
         wechat.multiRegister( pack , function(){ alert("error")})
    }
    //getOwner
    function getOwner(){
        wechat.getOwner( function(data){
            console.log( data )
        });
    }
    //getContacts
    function getContacts(){
        wechat.getContacts( function(data){
            console.log(data)
        });
    }
    //undeliverd
    function undelivered(){
        wechat.undelivered(function( obj ){
            for(var i=0 ; i < obj.data.length;i++){
                //console.log(  obj.data[i] );
                var pack = {"cid": obj.data[i].cid ,
                           "channel":obj.data[i].channel,
                           "device":"desktop|mobile",
                           "action": obj.data[i].action,
                           "sid":obj.data[i].sid,
                           "tid":obj.data[i].tid,
                           "gid":obj.data[i].gid,
                           "corps":obj.data[i].corps,
                           "category":obj.data[i].category,
                           "data":obj.data[i].data,
                           };
            
                wechat.send(pack);
            }
        });
    }
    //querydbdate
    function querydbdate(){
        var pack = { channel:$("#xchannel").val() ,offset:0, limit:10 };
        console.log(pack);
        wechat.querydbdate( pack , function(data){
                                console.log( data );
                           } , function(err){
                                alert("eror");
                           });
    }
    //openrooms
    function openrooms(){
        //action: "open"|"close"
        var pack = { channel:$("#xchannel").val() , action:"open" };
        wechat.openrooms( pack );
    }
    //closerooms
    function closerooms(){
        //action: "open"|"close"
        var pack = { channel:$("#xchannel").val(), action:"close" };
        wechat.openrooms( pack );
    }
    function getOpenRooms(){
        var pack = { channel:$("#xchannel").val() , from: "u0001" };
        wechat.getOpenRooms( pack , function(obj){
            console.log(obj);
            for (var i=0 ; i< obj.data.length ; i++){
                console.log( obj.data[i].sid );
                console.log( obj.data[i].starttime );
                console.log( obj.data[i].endtime );
            }
        });
    }
    //onlines
    function getOnLineUsers(){
        var users = [] ;
        
        var user00 = { sid: "u0001"};
        users.push( user00);
        
        var user01 = { sid: "u0002"};
        users.push( user01) ;
        
        var pack = { data: users };
        wechat.getOnLineUsers( pack , function(obj){
            console.log( pack  );
        });
    }
    //crudNews
    function crudNews(){
        //insert
        var mydata = [ { title:"mytitle0", content:"mycontent0" , created_time:"1478486744549"},
                      { title:"mytitle1", content:"mycontent1" , created_time:"1478486744555"}];
        
        var pack = { action:"insert" ,data: mydata};
        wechat.crudNews( pack , function(){
                console.log("success");
        });
        
        //query
        var pack = { action:"query", offset:0, limit:10 };
        wechat.crudNews(pack , function(obj){
                console.log( obj );
        });
    }
    //crudTsFlag
    function crudTsFlag(){
        //update|insert
        var mydata = [ ]
        var pack = { action:"update" ,flag:"news" , ts:"1234567890123"};
        wechat.crudTsFlag( pack , function(obj){
            console.log("ok");
        });
        
        //query
        var pack = { action:"query",flag:"news"};
        wechat.crudTsFlag(pack , function(obj){
            console.log( obj );
        });
    }
    //clear db
    function resetdb(){
        var pack = { db: "ChatHistory|Contacts|OpenRooms|ChatNews|ChatTsFlag"};
        
        wechat.resetdb( pack , function(data){
            console.log( data );
        });
    }
    //clear db && variable
    function clearall(){
        //reset db
        resetdb()
        
        //clear
        wechat.clear()
    }
   
    //myclear
    function myclear(){
        $("#message").empty();
    }
</script>
    
</body>
</html>
```

## Current status

Done  work:
* Auto  Connect  and Reconnect  your Server
* Auto Subscirbe  your  device.uuid   channel
* Always  Service  is  running

## History

* **v1.0.1** : 2017-05-26
