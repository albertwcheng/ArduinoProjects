/*
 
 This script uses a button to fade an LED -- with an easing equation for smoothness.
 
 This script allows you to use a button to turn an LED on and off (with fading).
 We use digitalRead() to get the value from the button.
 We use analogWrite() to set the brightness of the LED.
 We use an easing equation (thanks to Robert Penner) to make the fading smooth.
 We use a timer to allow us to have a specific clock speed (see note below).
 
 The circuit:
 * LED attached from digital pin 9 to ground.
 * Button with one leg connected to digital pin 8 and ground through a 10k resistor, while the other leg is connected to source voltage.
 
 
 created 2010
 by Andrew Frueh
 
 I built this code starting with "Fading" from Arduino examples - 1 Nov 2008, By David A. Mellis
 http://arduino.cc/en/Tutorial/Fading
 
*/

// You can change the settings here
// >>
// fadeTimerFreq is the clock speed in milliseconds, lower numbers are faster
const int fadeTimerFreq = 30;
// fadeTime is the total time it will take to complete the ease (in milliseconds)
const int fadeTime = 3000;
// <<

// additional variable for the timer
int currentTime, fadeTimerLast;

// these constant variables store the pin numbers
const int ledPin = 9;
const int buttonPin = 8;
const int fadeRange = 254;


// the amount to step the fade; must be between 1 and the fadeRange
const float fadeStep = (float(fadeTimerFreq) / (fadeTime)) * fadeRange;

int buttonValue, fadeTarget, fadeValueTweened;
float fadeValue;

void setup()  {
  // initialize the serial port; needed for debugging below
  Serial.begin(9600);
  // initialize the LED pin
  pinMode(ledPin, OUTPUT);
  // initialize the input pin
  pinMode(buttonPin, INPUT);
}

void loop()  {

  // for all timers
  currentTime = millis();

  // checks to see if the number of milliseconds has passed
  if ( abs(currentTime - fadeTimerLast) >= fadeTimerFreq) {
    fadeTimerLast = currentTime;
   
    // read the value from the input
    buttonValue = digitalRead(buttonPin);
    // step the fading
    if(buttonValue == 1){
      // if the button is pressed, increase the fade
      fadeValue = fadeValue + fadeStep;
    }
    else{
      // if the button is not pressed, decrease the fade
      fadeValue = fadeValue - fadeStep;
    }
    // constrain the fadeValue so it can't go off toward infinity
    fadeValue = constrain(fadeValue, 0, fadeRange);

    // get the tweened value -- i.e. the smooth value
    fadeValueTweened = Quad_easeInOut(fadeValue, 0, fadeRange);
    // use the tweened value to set the brightness of the LED
    analogWrite(ledPin, fadeValueTweened);
    // print the values to the serial port for debugging
    Serial.print(buttonValue);
    Serial.print(", ");
    Serial.println(fadeValue);
  }
}


// Quad easing thanks to Robert Penner
// variables used are type "float" so that you can throw smaller numbers at it and it will still work well
float Quad_easeInOut(float t, float fixedScaleStart, float fixedScaleEnd){
  // float b = 0, c = 1, d = 1;
  float b = fixedScaleStart;
  float c = fixedScaleEnd - fixedScaleStart;
  float d = fixedScaleEnd;
  if ((t/=d/2) < 1) return c/2*t*t + b;
  return -c/2 * ((--t)*(t-2) - 1) + b;
}

