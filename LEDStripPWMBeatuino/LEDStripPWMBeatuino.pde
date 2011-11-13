/*
#define GREEN_PIN 4
#define BLUE_PIN 8
#define RED_PIN 13

*/

#define GREEN_PIN 3
#define BLUE_PIN 5 
#define RED_PIN 6

#define USERESCALE 0

#define baseLEDPin 2
#define topLEDPin 11
#define beatLEDPin 12

int sensorValue; 
unsigned long newTime;
int avg;
#define CONVERGE 100
#define PEAK 1.3


#define NOISE_SAMPLING_STEPS CONVERGE //100
//unsigned long average[10];
#define BEATONLENGTH 50


int beatCounter;

double rescale(double value,double inlow,double inhigh,double outlow,double outhigh){
  return  (value-inlow)/(inhigh-inlow)*(outhigh-outlow)+outlow;
}





int counter;

long noise;
int noiseSamplerCount;

int beatSeqLED[]={12,A4,A3,A2};
#define NUMBEATSEQ 4

void setupBeatDetection()
{

  counter=0;
  avg=0;
  beatCounter=0;
  noiseSamplerCount=0;
  noise=0;
  newTime=-1;

}

char buff[1000];


bool between(unsigned long value,unsigned long low,unsigned long hi){
  return (value>=low && value<hi); 
}


int COLORS[8][3]=
{ {0,0,0},
  {0,0,1},
  {0,1,0},
  {0,1,1},
  {1,0,0},
  {1,0,1},
  {1,1,0},
  {1,1,1}};
  

void setColor(int *RGB){

  digitalWrite(RED_PIN,RGB[0]?HIGH:LOW);
  digitalWrite(GREEN_PIN,RGB[1]?HIGH:LOW);
  digitalWrite(BLUE_PIN,RGB[2]?HIGH:LOW);
  
}

void setColorPWM(int *RGB){
  analogWrite(RED_PIN,RGB[0]);
  analogWrite(GREEN_PIN,RGB[1]);
  analogWrite(BLUE_PIN,RGB[2]);    
}

int curColor=0;
int curRGBPWM[3]={0,0,0};
int curInc[3]={0,0,0};
int LoBounds[3]={0,0,0};
int HiBounds[3]={255,255,255};
int delayTime=20;



void initSleepLightRoutine(){
    for(int i=0;i<3;i++){
      curRGBPWM[i]=0;
      curInc[i]=-1;
  }
  
  delayTime=20;
}

void initRedBlueFade(){
  curRGBPWM[0]=255;
  curInc[0]=1;
  
  curRGBPWM[2]=0;
  curInc[2]=-1;
 
  
  
  delayTime=20;
}


void setupLEDStrip()
{
  initRedBlueFade();
  randomSeed(analogRead(0));

  pinMode(GREEN_PIN, OUTPUT);   
  pinMode(RED_PIN, OUTPUT);  
  pinMode(BLUE_PIN, OUTPUT);   
}

void setup() {                
  Serial.begin(9600);
 // initSleepLightRoutine();

  
  
  setupBeatDetection();
  
}

void simpleLoopColorRoutine(){
   if(curColor>=8){
     curColor=0; 
  }
  
  setColor(COLORS[curColor]);
  
  curColor++;
  delay(1000);  
}


void PWMLoopColorRoutine(){
  for(int i=0;i<3;i++){
    if(curRGBPWM[i]<=LoBounds[i] || curRGBPWM[i]>=HiBounds[i] ){
       curInc[i]=-curInc[i];
    } 
  }
  

  setColorPWM(curRGBPWM);
  
  
  for(int i=0;i<3;i++){
    curRGBPWM[i]+=curInc[i]; 
  }
  
  delay(delayTime);
}


void PWMLoopRandomRoutine(){
    for(int i=0;i<3;i++){
       curRGBPWM[i]=random(1,256);
       
    }
   setColorPWM(curRGBPWM);
   delay(200);  
}

void showRandomColor(){
    for(int i=0;i<3;i++){
       curRGBPWM[i]=random(1,256);
       
    }
   setColorPWM(curRGBPWM);
}

void offLEDStrip(){
  for(int i=0;i<3;i++)
    curRGBPWM[i]=0;
   
    setColorPWM(curRGBPWM);  
}

int LEDSTATUS=0;

void loop() {
 // simpleLoopColorRoutine();
//PWMLoopColorRoutine();
//PWMLoopRandomRoutine();

    sensorValue=analogRead(0);
  if(noiseSamplerCount<NOISE_SAMPLING_STEPS){
     noise+=sensorValue;
     //sprintf(buff,"Step %d Sampling: %d => accum %d",noiseSamplerCount+1,sensorValue,noise);
    // Serial.println(buff);
     noiseSamplerCount++;
    return; 
    
  }else if(noiseSamplerCount==NOISE_SAMPLING_STEPS){
   // sprintf(buff,"NoiseAccum=%d",noise);
   //  Serial.println(buff);
    noise=noise/NOISE_SAMPLING_STEPS;
    noiseSamplerCount++; 
    sprintf(buff,"Noise=%d",noise);
    
    
    Serial.println(buff);
    
    //send a noise sampling done flash pattern
    offLEDStrip();
    curRGBPWM[0]=255;
    setColorPWM(curRGBPWM);
    delay(500);
    offLEDStrip();
    curRGBPWM[1]=255;
    setColorPWM(curRGBPWM);
    delay(500);   
    offLEDStrip();
    curRGBPWM[2]=255;
    setColorPWM(curRGBPWM);
    delay(500); 
    offLEDStrip();
    delay(500); 
  }
   
   
 
   
  int diff=sensorValue - avg;
  avg+=diff/CONVERGE;
  
  int rescaled=rescale(sensorValue,noise,1023,0,10);
  
  
  if(USERESCALE){
    if(rescaled>=5){
       newTime=millis();

       
       if(!LEDSTATUS){
                Serial.println("beep");
      showRandomColor();
      LEDSTATUS=1;
       }
    }
  }
  else{
    
    
    if(sensorValue>avg*PEAK){
       newTime=millis();
       
       if(!LEDSTATUS){
         Serial.println("beep");
      showRandomColor();
      LEDSTATUS=1;
       }
    }
    

  
  }

  if(millis()-newTime>100){
       offLEDStrip();
       LEDSTATUS=0;
  }
}
