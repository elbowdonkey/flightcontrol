#include <VarSpeedServo.h>
#include <Bounce.h>
#include <EEPROM.h>
#include "EEPROMAnything.h"


// PINS
#define auxPin          7   // input pin for signal wire from rx AUX channel
#define leftFlapServo   3   // output pin for left flap servo
#define rightFlapServo  5   // output pin for right flap servo
#define redLedPin       11  // output pin for red LED
#define greenLedPin     13  // output pin for green LED
#define blueLedPin      14  // output pin for blue LED
#define potPin          0   // analog input pin for potentiometer
#define switchPin       9   // digital input for momentary switch

// CONSTANTS
#define servoSpeed      15  // speed at which the servos should move (0-255, 255 being the fastest)
#define sampleCount     50  // when averaging signals, how many readings should we take?
#define ledDelay        125
#define ledCycles       1

VarSpeedServo LeftFlap;
VarSpeedServo RightFlap;
Bounce setupSwitch = Bounce(switchPin, 10);

volatile int auxSignal;         // value of the rx AUX channel's signal
int rxOk;                       // flag to indicate that the rx is producing data
int auxSignalToServo;           // rx AUX channel value mapped to servo friendly 0-180
int inverseAuxSignal = 0;       // used to flip the AUX signal value for one of the flap servos
int systemState = 1;            // 0 == setup, 1 == normal running mode
int currentPotValue;
int normalizedPot;

// TIMERS
elapsedMillis sincePrint;
elapsedMillis servoPosTimer;

struct settings_t
{
    int flapsUpTarget;          // the servo position of the flaps in "up" mode
    int flapsDownTarget;        // the servo position of the flaps in "down" mode
} settings;                     // settings are stored using EEPROM

/*
  total inputs:
  flaps up
  flaps down
  momentary switch
  potentiometer

  button up + pot at zero = enter flap position setup
    led blinks red
    pot now applies current pot value to servos
    button up saves current pot value to flapsUpTarget or flapsDownTarget depending on position of flaps switch
    led blinks green quickly 5 times
    led solid green for 50ms
    now in "running" state

*/

void setup()
{
  pinMode(potPin, INPUT);
  pinMode(switchPin, INPUT_PULLUP);

  LeftFlap.attach(leftFlapServo);
  RightFlap.attach(rightFlapServo);

  // get settings
  EEPROM_readAnything(0, settings);
  Init_LEDs();

  // force setup if settings haven't been saved yet
  if (firstTime()) {
    systemState = 0;
  }

  // force setup if pot is at zero
  if (analogRead(potPin) == 0) {
    settings.flapsUpTarget = -1;
    settings.flapsDownTarget = -1;
    systemState = 0;
  }
}

void loop()
{
  switch(systemState)
  {
    case 0:
      currentPotValue = analogRead(potPin);
      auxSignalToServo = readAux();
      normalizedPot = map(analogRead(potPin), 0, 1024, 0, 180);

      //
      int servoPosTarget;

      inverseAuxSignal = map(normalizedPot, 180, 0, 0, 180);
      LeftFlap.slowmove(normalizedPot,servoSpeed);
      RightFlap.slowmove(inverseAuxSignal,servoSpeed);
      //

      if (setupSwitch.update()) {
        if (setupSwitch.fallingEdge()) {
          Serial.println(normalizedPot);

          if (flapsUp()) {
            settings.flapsUpTarget = normalizedPot;
            blinkBlue();
          } else {
            settings.flapsDownTarget = normalizedPot;
            blinkWhite();
          }

          if (settings.flapsUpTarget >= 0 && settings.flapsDownTarget >= 0) {
            EEPROM_writeAnything(0, settings);
            blinkGreen();
            systemState = 1;
          }

          break;
        }
      }

      while (sincePrint > 3000) {
        sincePrint = 0;
        blinkRed();
      }
      break;

    case 1:
      while (servoPosTimer > 250) {

        int servoPosTarget;

        if (flapsUp()) {
          servoPosTarget = settings.flapsUpTarget;
        } else {
          servoPosTarget = settings.flapsDownTarget;
        }

        inverseAuxSignal = map(servoPosTarget, 180, 0, 0, 180);
        LeftFlap.slowmove(servoPosTarget,servoSpeed);
        RightFlap.slowmove(inverseAuxSignal,servoSpeed);
        servoPosTimer = 0;
      }

      break;
    default:
      systemState = 0;
      break;
  }
}

bool firstTime() {
  return (settings.flapsUpTarget < 0 || settings.flapsDownTarget < 0);
}

float readAux(){
   // read multiple values and sort them to take the mode
   int sortedValues[sampleCount];
   for(int i=0;i<sampleCount;i++){
     int value = readSignal();
     int j;
     if(value<sortedValues[0] || i==0){
        j=0; //insert at first position
     }
     else{
       for(j=1;j<i;j++){
          if(sortedValues[j-1]<=value && sortedValues[j]>=value){
            // j is insert position
            break;
          }
       }
     }
     for(int k=i;k>j;k--){
       // move all values higher than current reading up one position
       sortedValues[k]=sortedValues[k-1];
     }
     sortedValues[j]=value; //insert current reading
   }
   //return scaled mode of 10 values
   float returnval = 0;
   for(int i=sampleCount/2-5;i<(sampleCount/2+5);i++){
     returnval +=sortedValues[i];
   }
   returnval = returnval/10;
   return returnval*1100/1023;
}

int readSignal() {
  int direction = 0;
  auxSignal = pulseIn(auxPin, HIGH, 20000);

  if (auxSignal == 0) {
    auxSignal = rxOk;
  } else {
    rxOk = auxSignal;
  }
  auxSignalToServo = map(auxSignal, 1000, 2000, 0, 180);
  return auxSignalToServo;
}

bool flapsUp() {
  int a = readAux();
  return (a < 50);
}