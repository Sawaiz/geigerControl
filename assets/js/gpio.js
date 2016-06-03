// Let us open a web socket
var ws;
var positionList;

function connect(){
  ws = new WebSocket("ws://192.168.100.218/ws");
  ws.onopen = function(){
    ws.send("clientsAvailable");
    ws.send("lvStatus");
  };
  ws.onmessage = function (evt) {
    var received_msg = evt.data;
    received_msg = received_msg.split(" ");
    if(received_msg[0] === "positionList"){
      positionList = JSON.parse(received_msg[1]);
      for(i in positionList){
        addHVControl(positionList[i][0], positionList[i][1]);
      }
    } else if (received_msg[0] === "lv") {
      var header = document.getElementById('titleHeader');
      if (Number(received_msg[1]) === 0) {
        header.style.color = "#B1463C";
      } else {
        header.style.color = "#377D7E";
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

function sendVoltage(device, voltage){
  ws.send("hv" + " " + voltage + " " + device);
}

function setAllToDefault(){
  for(var i in positionList){
    sendVoltage(positionList[i][0], positionList[i][1]);
  }
}

function setAllTo(value){
  for(var i in positionList){
    sendVoltage(positionList[i][0], value);
  }
}

function lowVoltage(state){
  ws.send("lv" + " " + state);
}

function addHVControl(device ,datasheetVoltage) {

  var hvControlSection = document.createElement("section");
  var imgLink = document.createElement("a");
  var img = document.createElement("img");
  var contentDiv = document.createElement("div");
  var innerDiv = document.createElement("div");
  var header = document.createElement("h2");
  var discription = document.createElement("p");
  var actionList = document.createElement("ul");
  var inputListelement = document.createElement("li");
  var inputDiv = document.createElement("div");
  var input = document.createElement("input");
  var buttonListelement = document.createElement("li");
  var setVoltageButton = document.createElement("a");

  hvControlSection.appendChild(imgLink);
  imgLink.appendChild(img);
  hvControlSection.appendChild(contentDiv);
  contentDiv.appendChild(innerDiv);
  innerDiv.appendChild(header);
  innerDiv.appendChild(discription);
  innerDiv.appendChild(actionList);
  actionList.appendChild(inputListelement);
  actionList.appendChild(buttonListelement);
  inputListelement.appendChild(inputDiv);
  inputDiv.appendChild(input);
  buttonListelement.appendChild(setVoltageButton);

  imgLink.className += " image";
  contentDiv.className += " content";
  innerDiv.className += " inner";
  actionList.className += " actions";
  inputDiv.className += " 6u 12u$(xsmall)";
  setVoltageButton.className += " button";

  var deviceLabel = document.createTextNode(device + " finger voltage.");
  var dsVoltage = document.createTextNode("Voltage for MPPC " + datasheetVoltage + "V.");
  var buttonLabel = document.createTextNode("Set Voltage for " + device);

  header.appendChild(deviceLabel);
  discription.appendChild(dsVoltage);
  discription.appendChild(dsVoltage);
  setVoltageButton.appendChild(buttonLabel);

  imgLink.setAttribute("href", "assets/images/"+device+".png");
  img.setAttribute("alt", "");
  img.setAttribute("data-position", "center center");
  imgLink.style.backgroundImage = "url('assets/images/"+device+".png')";
  imgLink.style.backgroundPosition = "50% 0%";
  img.setAttribute("style", "background-image");
  input.setAttribute("type", "text");
  input.setAttribute("id", device);
  input.setAttribute("name", "voltage");
  input.setAttribute("value", datasheetVoltage);
  input.setAttribute("placeholder", "Voltage");
  setVoltageButton.addEventListener('click', function(){sendVoltage(device, document.getElementById(device).value);});

  document.getElementById("one").appendChild(hvControlSection);
}
