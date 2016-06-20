var ws;

function connect(){
  ws = new WebSocket("ws://"+location.hostname+":81");
  ws.onopen = function(){
    setInterval(function(){
      ws.send("availableNetworks");
    }, 5000);
  };
  ws.onmessage = function (evt) {
    var received_msg = evt.data;
    received_msg = received_msg.split(",");

    if(received_msg[0] === "positionList"){
      positionList = JSON.parse(received_msg[1]);
      for(i in positionList){
        addHVControl(positionList[i][0], positionList[i][1]);
      }
    } else if (received_msg[0] === "newAP") {
      addNetworks(received_msg);
    } else{
      for (var i = 0; i < received_msg.length; i++) {
        var lastMessage = document.getElementById('lastMessage');
        lastMessage.innerHTML=received_msg[i];
      }
    }
  };
  ws.onclose = function(){
    // websocket is closed.
    alert("Connection is closed...");
    setTimeout(connect, 5000);
  };
  var iv = setInterval(function () {
    ws.send("ping");
  }, 30000);
}
connect();

function testDOMChange(){
  addNetworks(["newAP","AinWork","-81","heMayCallYou","-54","Flesh and Bone all wrapped up in skin","-81","in a manner of speaking","-56"]);
}

function addNetworks(received_msg){
  if(received_msg.length == 1){
    //remove wifiinfo and return
    if(document.getElementById("wifiInfo")){
      var parent = document.getElementById("mainHeader");
      var child = document.getElementById("wifiInfo");
      parent.removeChild(child);
    }
    return;
  }
  received_msg.shift();
  if(document.getElementById("wifiInfo")==null){
    //Create wifiInfo Section
    var wifiInfo = document.createElement("div");
    wifiInfo.setAttribute("id", "wifiInfo");
    document.getElementById("mainHeader").appendChild(wifiInfo);
  }
  if(document.getElementById("nearbyNetworks")==null){
    //Create Nearby Networks Section
    var nearbyNetworks = document.createElement("div");
    nearbyNetworks.setAttribute("id", "nearbyNetworks");
    document.getElementById("wifiInfo").appendChild(nearbyNetworks);
  }else{
    //Clear out Nearby Networks
    var myNode = document.getElementById("nearbyNetworks");
    while (myNode.firstChild) {
      myNode.removeChild(myNode.firstChild);
    }
  }
  if(document.getElementById("knownNetworks")==null){
    //Create known Networks Section
    var knownNetworks = document.createElement("div");
    knownNetworks.setAttribute("id", "knownNetworks");
    document.getElementById("wifiInfo").appendChild(knownNetworks);
  }
  var numNetworks = (received_msg.length/2)-1;
  for(i = 0; i < numNetworks; i++){
    //Create element
    var newAP = document.createElement("p");
    var APinfo = document.createTextNode(received_msg[1] + "dB " + received_msg[0]);
    newAP.setAttribute("id", received_msg[0]);
    newAP.appendChild(APinfo);
    document.getElementById("nearbyNetworks").appendChild(newAP);
    received_msg.shift();
    received_msg.shift();
  }
}

function changeWebAP(){
  var ssid = document.getElementById("ssid").value;
  var password = document.getElementById("password").value;
  ws.send("changeAP,"+ssid+","+password);
}
