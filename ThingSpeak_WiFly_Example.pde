/**
  ThingSpeak w/ Arduino Uno + WiFly Example
  Demonstrates very basic single analog input to ThingSpeak update (GET) using the
  SparkFun Electronics WiFly sheild.
  
  Resources:
    - ThingSpeak            - http://thingspeak.com
    - SparkFun Electronics  - http://www.sparkfun.com/products/9954
 
  Notes:
    - Please verify that your WiFly shield is able to connect prior to attempting to use this code.
      Some good tips can be found at: http://forum.sparkfun.com/viewtopic.php?f=32&t=25129
    - SSID, password and ThingSpeak API key are set within "Credentials.h"
 
  Created by Andrew Sliwinski (andrew@unitedworkshop.com)
  http://github.com/thisandagain/
 
  Based on the WiFly 2.0 alpha library from SparkFun Electronics
**/
 
#include "WiFly.h"
#include "Credentials.h"

// Sensor parameters
int sensorPin            = A0;

// Server parameters
Client client("api.thingspeak.com", 80);
String uri               = String("GET /update?key=");
String query             = String("&field1=");
String method            = String(" HTTP/1.0");
String request           = String("");

// General
long previousMillis      = 0;        
long interval            = 30000;             // Milliseconds (30 seconds)

/**
 * Setup
 **/
void setup() {
  
  // Serial
  Serial.begin(9600);

  // WiFly
  WiFly.begin();
  
  if (!WiFly.join(ssid, passphrase)) {
    Serial.println("Association failed.");
    while (1) {
      // Hang on failure.
    }
  }
  
  // Establish connection
  Serial.println("connecting...");

  if (client.connect())
  {
    Serial.println("connected");
  } else {
    Serial.println("connection failed");
  }
}

/**
 * Loop
 **/
void loop() {
  // Sensor update
  unsigned long currentMillis = millis();
 
  if (currentMillis - previousMillis > interval)
  {
    // Save last update 
    previousMillis       = currentMillis;
    
    if (!client.connected())
    {
      if (client.connect())
      {
        Serial.println("connected");
      } else {
        Serial.println("connection failed");
      }
    }

    // Trigger update
    request              += uri + apikey + query + analogRead(sensorPin) + method;
    client.println(request);
    client.println();
    
    // Clear request
    request              = "";
    
    // Close connection
    if (!client.connected())
    {
      Serial.println();
      Serial.println("disconnecting.");
      client.stop();
    }
  }
  
  // Server response
  if (client.available())
  {
    char c = client.read();
    Serial.print(c);
  }
}
