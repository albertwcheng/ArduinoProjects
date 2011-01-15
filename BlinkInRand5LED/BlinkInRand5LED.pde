/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */

int LEDs[]={13,12,8,7,4};
#define NUM_LEDS 5
int curLED=0;

void setup() {                
  // initialize the digital pin as an output.
  for(int i=0;i<NUM_LEDS;i++)
    pinMode(LEDs[i], OUTPUT); 

}



void loop() {
  
  curLED=rand()%NUM_LEDS
  
  int LEDPin=LEDs[curLED];
  digitalWrite(LEDPin, HIGH);   // set the LED on
  delay(50);              // wait for a second
  digitalWrite(LEDPin, LOW);    // set the LED off
  delay(50);              // wait for a second

}
