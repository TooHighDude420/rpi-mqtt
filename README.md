Run the docker container on the RPi

or do it manually with:
```bash
sudo apt install mosquitto python3 python3-pip
#might need --break-system-packages
python3 -m pip install -r requirements.txt
mosquitto -c path_to_conf &
python3 path_to_main
```

start the private network with (hopefully):
```bash
sudo nmcli device wifi hotspot ifname wlan0 \
  con-name iot-hotspot \
  ssid E-TabelNet \
  password "TempEPass"
```

the MQTT broker is reachabble via the ip of the RPi findable wit ```ip a``` command, the port is 1883 so for example 10.xxx.xxx.x:1883

Put this on the ESP32 and test if it works, it should show "i am connected" on the RPi
```c++ 
#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
 
const char* ssid = "E-TabelNet";
const char* password = "TempEPass";
 
// Replace with your MQTT broker IP address
const char* mqtt_server = "RPI IP";
 
//MQTT topic
const char* mqtt_topic = "master/updates";
 
//MQTT client device name
const char* client_name = "slave/1";
 
WiFiClient espClient;
PubSubClient client(espClient);
 
void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(100); }
  
  Serial.println();
  Serial.println("******************************************************");
  Serial.print("Connecting to ");
  Serial.println(ssid);
 
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
 
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  // Connect to MQTT broker
  client.setServer(mqtt_server, 1883);
  while (!client.connected()) {
    Serial.println("Connecting to MQTT broker...");
    if (client.connect(client_name)) {
      Serial.println("Connected to MQTT broker");
    } else {
      Serial.print("Failed with state ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}
 
void loop() {
  if (!client.connected()) {
    Serial.println("not Connected to MQTT broker");
  }
 
  JsonDocument doc;
  doc["command"] = "update";
  doc["message"] = "i am connected";
  doc["device_ID"] = client_name;
  
  // Serialize JSON object to string
  char jsonBuffer[200];
  serializeJson(doc, jsonBuffer);
 
  // Publish JSON string to MQTT broker
  char s[80];
  strcpy(s, mqtt_topic);
  strcat(s, client_name);
  while (!client.connected()) {
    Serial.println("Connecting to MQTT broker...");
    if (client.connect("ESP32_IOT_Sensor")) {
      Serial.println("Connected to MQTT broker");
    } else {
      Serial.print("Failed with state ");
      Serial.println(client.state());
      delay(2000);
    }
  }
  Serial.println(client.publish(s, jsonBuffer));
  Serial.println(jsonBuffer);
  Serial.println(s);
  delay(5000);
}
 
```

to stop the network:
sudo nmcli connection down iot-hotspot
