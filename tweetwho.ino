#include "Charliplexing.h"
#include "Myfont.h"
#include "Arduino.h"

//int leng=0; //provides the length of the char array
char test[]="x\0"; //text has to end with '\0' !!!!!!
String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete
int lastReading=0;
int reading=1; 
 
void setup()                    // run once, when the sketch starts
{
  LedSign::Init();  
  //setLength();
  Serial.begin(9600);
  Serial.println("Start");
  pinMode(4, INPUT);
  // reserve 200 bytes for the inputString:
  inputString.reserve(200);
}

void loop()
{ 
  //  Serial.println(analogRead(4));
  // send data only when you receive data:
  if (stringComplete) {
    inputString += '\0';
    inputString.toCharArray(test, inputString.length());
    //Serial.println(inputString);
    Myfont::Banner(inputString.length(), (unsigned char *)test);
    inputString = "";
    stringComplete = false;    
  }
  
  Serial.println(analogRead(4));
  delay(200);
  /*
  reading = analogRead(4); 
  
  if ((lastReading > (reading+30)) || (lastReading < (reading-30))) { 
    Serial.println(reading); 
  }
  lastReading = reading;  */
}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read(); 
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:    
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}
/*
void setLength() {
  for(int i=0; ; i++){ //get the length of the text
    if(test[i]==0){
      leng=i;
      break;
    }
  }
}*/
