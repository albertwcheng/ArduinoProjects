

int LEDs[]={13,12,11,7,6,5,3,2};
#define COMMON_ANODE 4
#define NUM_LEDS 8
#define NUMBITS 8
int curNumber=0;

int digits[10][8]={
  {0,1,1,1,1,1,1,0}, //0
  {0,0,0,1,0,0,1,0}, //1
  {1,0,1,1,1,1,0,0}, //2
  {1,0,1,1,0,1,1,0}, //3
  {1,1,0,1,0,0,1,0}, //4
  {1,1,1,0,0,1,1,0}, //5
  {1,1,1,0,1,1,1,0}, //6
  {0,0,1,1,0,0,1,0}, //7
  {1,1,1,1,1,1,1,0}, //8
  {1,1,1,1,0,1,1,0}, //9
};

int dp[8]={-1,-1,-1,-1,-1,-1,-1,1};  //add a dp to the display

void displayChr(int anode,const int* leds,const int *bits,int numBits){
   digitalWrite(anode,HIGH);
   for(int i=0;i<numBits;i++){
     if(bits[i]==-1){ 
       //skip this pin status
       continue;
     }
     digitalWrite(leds[i],!bits[i]);
   }
}


  
void initLeds(int anode,const int *leds,int numBits){
   for(int i=0;i<numBits;i++){
     pinMode(leds[i],OUTPUT);
     digitalWrite(leds[i],HIGH);
   } 
   pinMode(anode,OUTPUT);
   digitalWrite(anode,HIGH);
}

void setup() {                

 initLeds(COMMON_ANODE,LEDs,NUMBITS);
}



void loop() {
  
  if(curNumber==10)
    curNumber=0;
    
  displayChr(COMMON_ANODE,LEDs,digits[curNumber],NUMBITS);
  delay(500);
  displayChr(COMMON_ANODE,LEDs,dp,NUMBITS);
   delay(500);
  curNumber++;
}
