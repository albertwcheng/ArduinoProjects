

int LEDs[]={13,12,9,7,4};
#define NUM_LEDS 5
#define RANDOM_LIGHTS 0
#define ORDERED_LIGHTS 1
#define OFF 2
int curLED=0;
int showMODE=RANDOM_LIGHTS;
int blinkCount=0;
int button=8;
int buttonOn=0;

void setup() {                
  // initialize the digital pin as an output.
  for(int i=0;i<NUM_LEDS;i++)
    pinMode(LEDs[i], OUTPUT); 
  
  pinMode(button, INPUT);
  Serial.begin(9600);
  Serial.println("Ready");
}

void showLight(int LEDPin){
    digitalWrite(LEDPin, HIGH);   // set the LED on
  delay(50);              // wait for a second
  digitalWrite(LEDPin, LOW);    // set the LED off
  delay(50);              // wait for a second
}

void randomLights(){
    curLED=rand()%NUM_LEDS;
  
  showLight(LEDs[curLED]);

}

void orderedLights(){
  if(curLED==NUM_LEDS)
   curLED=0;
   
  showLight(LEDs[curLED]);
   
  curLED++;

}

void offMode(){
   //just sleep
  delay(100); 
}


char buffer[100];


void loop() {
  blinkCount++;
  if(blinkCount%10==1){
    //sprintf(buffer,"blinking %d time",blinkCount);
    //Serial.println(buffer);
    //Serial.println("hello");
  }
  if(digitalRead(button)){
     buttonOn++;
  }else
  {
     buttonOn=0; 
  }
     //toggle mode
     
  if(buttonOn==1){
  if( showMODE == RANDOM_LIGHTS){
     Serial.println("going to ordered lights mode");
     showMODE=ORDERED_LIGHTS;}
   else if(showMODE==ORDERED_LIGHTS){
      Serial.println("going off");
    showMODE=OFF;}
   else if(showMODE==OFF){
      Serial.println("going to random lights mode");
      showMODE = RANDOM_LIGHTS;
   };
  }

  switch(showMODE){
    case RANDOM_LIGHTS:
    randomLights();
    break;
    case ORDERED_LIGHTS:
    orderedLights(); 
    break;
    case OFF:
    default:
    offMode();
  }
}
