/*
To upload through terminal you can use: curl -F "image=@firmware.bin" esp8266-webupdate.local/update
*/

#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ESP8266HTTPUpdateServer.h>
#include <WebSocketsServer.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266SSDP.h>
#include "FS.h"

const char* host = "esp8266";
const char* ssid = "geiger";
const char* password = "password";

ESP8266WebServer httpServer(80);
WebSocketsServer webSocket = WebSocketsServer(81);
ESP8266HTTPUpdateServer httpUpdater;
ESP8266WiFiMulti wifiMulti;

const int led = 16;
unsigned long previousMillis = 0;
unsigned long upkeepInterval = 250;

String getContentType(String filename){
  if(httpServer.hasArg("download")) return "application/octet-stream";
  else if(filename.endsWith(".htm")) return "text/html";
  else if(filename.endsWith(".html")) return "text/html";
  else if(filename.endsWith(".css")) return "text/css";
  else if(filename.endsWith(".js")) return "application/javascript";
  else if(filename.endsWith(".png")) return "image/png";
  else if(filename.endsWith(".gif")) return "image/gif";
  else if(filename.endsWith(".jpg")) return "image/jpeg";
  else if(filename.endsWith(".ico")) return "image/x-icon";
  else if(filename.endsWith(".xml")) return "text/xml";
  else if(filename.endsWith(".pdf")) return "application/x-pdf";
  else if(filename.endsWith(".zip")) return "application/x-zip";
  else if(filename.endsWith(".gz")) return "application/x-gzip";
  return "text/plain";
}

bool handleFileRead(String path){
  path = "/www"+path;
  Serial.println("handleFileRead: " + path);
  if(path.endsWith("/")) path += "index.html";
  String contentType = getContentType(path);
  String pathWithGz = path + ".gz";
  if(SPIFFS.exists(pathWithGz) || SPIFFS.exists(path)){
    if(SPIFFS.exists(pathWithGz))
    path += ".gz";
    File file = SPIFFS.open(path, "r");
    size_t sent = httpServer.streamFile(file, contentType);
    file.close();
    return true;
  }
  return false;
}

void handleNotFound() {
  // try to find the file in the flash
  if(handleFileRead(httpServer.uri())) return;

  digitalWrite ( led, 1 );
  String message = "File Not Found\n\n";
  message += "URI..........: ";
  message += httpServer.uri();
  message += "\nMethod.....: ";
  message += (httpServer.method() == HTTP_GET)?"GET":"POST";
  message += "\nArguments..: ";
  message += httpServer.args();
  message += "\n";
  for (uint8_t i=0; i<httpServer.args(); i++){
    message += " " + httpServer.argName(i) + ": " + httpServer.arg(i) + "\n";
  }
  message += "\n";
  message += "FreeHeap.....: " + String(ESP.getFreeHeap()) + "\n";
  message += "ChipID.......: " + String(ESP.getChipId()) + "\n";
  message += "FlashChipId..: " + String(ESP.getFlashChipId()) + "\n";
  message += "FlashChipSize: " + String(ESP.getFlashChipSize()) + " bytes\n";
  message += "getCycleCount: " + String(ESP.getCycleCount()) + " Cycles\n";
  message += "Milliseconds.: " + String(millis()) + " Milliseconds\n";

  httpServer.send(404, "text/plain", message);
  digitalWrite ( led, 0 );
}


void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t lenght) {

  switch(type) {
    case WStype_DISCONNECTED:
    Serial.printf("[%u] Disconnected!\n", num);
    break;
    case WStype_CONNECTED:
    {
      IPAddress ip = webSocket.remoteIP(num);
      Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
      webSocket.sendTXT(num, "Connected");
    }
    break;
    case WStype_TEXT:
    char *payloadSplit[100];
    for(int i = 0 ; i<100; i++){
      payloadSplit[i] = strtok_r((char*)payload, ",", (char**)&payload);
      if(payloadSplit[i] != NULL){
        Serial.println(payloadSplit[i]);
      }
    }

    if((strcmp(payloadSplit[0],"changeAP"))==0){
      // this opens the file "knownNetworks.txt" in append-mode
      File file = SPIFFS.open("/www/knownNetworks.txt", "a+");
      char str[100];
      strcpy(str,"ssid=");
      strcat(str,payloadSplit[1]);
      strcat(str,",password=");
      strcat(str,payloadSplit[2]);
      file.println(str);
      file.close();
      webSocket.sendTXT(num, "restart");
      ESP.restart();
    }

    if((strcmp(payloadSplit[0],"availableNetworks"))==0){
      int n = WiFi.scanNetworks();
      if (n != 0){
        String str = "newAP,";
        for (int i = 0; i < n; ++i){
          str=str+WiFi.SSID(i)+","+WiFi.RSSI(i)+",";
        }
        webSocket.sendTXT(num, str);
      }
    }

    // send message to client
    // webSocket.sendTXT(num, "message here");

    // send data to all connected clients
    // webSocket.broadcastTXT("message here");
    break;
    case WStype_BIN:
    Serial.printf("[%u] get binary lenght: %u\n", num, lenght);
    hexdump(payload, lenght);

    // send message to client
    // webSocket.sendBIN(num, payload, lenght);
    break;
  }

}

void setup(void){

  Serial.begin(115200);
  Serial.println();
  Serial.println("Booting Sketch...");

  WiFi.persistent(false);

  //mount file system
  bool result = SPIFFS.begin();
  Serial.println("SPIFFS opened: " + result);

  // WiFi.scanNetworks will return the number of networks found
  int n = WiFi.scanNetworks();
  Serial.println("scan done");
  if (n == 0)
  Serial.println("no networks found");
  else
  {
    Serial.print(n);
    Serial.println(" networks found");
    for (int i = 0; i < n; ++i)
    {
      // Print SSID and RSSI for each network found
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.print(")");
      Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE)?" ":"*");
      delay(10);
    }
  }
  Serial.println("");

  //look for knownNetworks file
  File knownNetworks = SPIFFS.open("/www/knownNetworks.txt", "r");
  if (knownNetworks){
    while(knownNetworks.available()) {
      //Lets read line by line from the file
      char accessPoints[256];
      knownNetworks.readStringUntil('\n').toCharArray(accessPoints,256);
      char accessPointSSID[128];
      char accessPointPassword[128];
      strtok(accessPoints, "=");
      strcpy(accessPointSSID,strtok(NULL, ","));
      strtok(NULL, "=");
      strcpy(accessPointPassword,strtok(NULL, "="));
      wifiMulti.addAP(accessPointSSID, accessPointPassword);
      Serial.println(accessPointSSID);
      Serial.println(accessPointPassword);
    }

    //Try to connect to AP 5 times
    for(int i = 0; i<5;i++){
      Serial.println("Connecting Wifi...");
      if(wifiMulti.run() == WL_CONNECTED) {
        Serial.println("");
        Serial.println("WiFi connected");
        Serial.println("IP address: ");
        Serial.println(WiFi.localIP());
        break;
      } else{
        delay(1000);
      }
    }
  }

  // otherwise, Just host your own
  if(WiFi.status() != WL_CONNECTED){
    WiFi.disconnect();
    Serial.println("Unable To Connect, Hosting AP");
    WiFi.mode(WIFI_AP_STA);
    WiFi.softAP(ssid, password);
  }
  knownNetworks.close();

  MDNS.begin(host);

  httpUpdater.setup(&httpServer);
  httpServer.onNotFound ( handleNotFound );
  httpServer.begin();

  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  MDNS.addService("http", "tcp", 80);
  Serial.printf("HTTPUpdateServer ready! Open http://%s.local/update in your browser\n", host);
}

void loop(void){
  httpServer.handleClient();
  webSocket.loop();
  delay(1);
}
