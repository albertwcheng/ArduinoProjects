/********

Copyright 2010 Wu Albert Cheng <albertwcheng@gmail.com>

LEDMatrixDisplay for Arduino

programmed to display message on LED matrix

******/

int rowPins[]={8,6,4,2,0};
int colPins[]={1,3,5,7,9,10,11,12};


#define MIN(x,y) ((x<y)?(x):(y))
#define MAX(x,y) ((x>y)?(x):(y))

#define NROWS 5
#define NCOLS 8

#define SHOWMIT   0
#define SHOWALBERTATMIT 1 
#define SHOWEACHLED  2
#define SHOWMODE  SHOWALBERTATMIT


//BITMAP LIBRARY:



char A5x5[][5]={
  {1,1,1,1,1},
  {1,0,0,0,1},
  {1,1,1,1,1},
  {1,0,0,0,1},
  {1,0,0,0,1} 
  
};

char L5x5[][5]={
  {1,0,0,0,0},
  {1,0,0,0,0},
  {1,0,0,0,0},
  {1,0,0,0,0},
  {1,1,1,1,1}
};

char B5x5[][5]={
  {1,1,1,1,0},
  {1,0,0,0,1},
  {1,1,1,1,0},
  {1,0,0,0,1},
  {1,1,1,1,0}
};

char E5x5[][5]={
  {1,1,1,1,1},
  {1,0,0,0,0},
  {1,1,1,1,1},
  {1,0,0,0,0},
  {1,1,1,1,1} 
};

char R5x5[][5]={
  {1,1,1,1,0},
  {1,0,0,0,1},
  {1,1,1,1,0},
  {1,0,0,1,0},
  {1,0,0,0,1} 
  
};

char T5x5[][5]={
  {1,1,1,1,1},
  {0,0,1,0,0},
  {0,0,1,0,0},
  {0,0,1,0,0},
  {0,0,1,0,0} 
};

char At5x5[][5]={
  {1,1,1,1,1},
  {1,0,1,0,1},
  {1,0,1,1,1},
  {1,0,0,0,0},
  {1,1,1,1,1} 
};

char M5x5[][5]={
  {1,0,0,0,1},
  {1,1,0,1,1},
  {1,0,1,0,1},
  {1,0,0,0,1},
  {1,0,0,0,1} 
};

char I5x5[][5]={
  {0,1,1,1,0},
  {0,0,1,0,0},
  {0,0,1,0,0},
  {0,0,1,0,0},
  {0,1,1,1,0} 
};








void updateDisplay(char *bmp,int startx,int starty,int widthDraw,int heightDraw,int wBmp,int hBmp)
{
   int displayWidth=8;
   int displayHeight=5;
   
   int boundDrawWidth=MIN(startx+widthDraw,wBmp);
   int boundDrawHeight=MIN(starty+heightDraw,hBmp);

   //clear the display first
   
   for(int drawY=0;drawY<displayHeight;drawY++)
   {
      digitalWrite(rowPins[drawY],HIGH); 
      
   }
   
   for(int drawX=0;drawX<displayWidth;drawX++)
   {
      digitalWrite(colPins[drawX],LOW); 
   }
   

   
   int curBmpY=starty;
   
   for(int drawY=0;drawY<displayHeight;drawY++)
   { 
     
     //is this drawY requesting already out of bound data?
     if(curBmpY>=boundDrawHeight)
        continue;
        
  
    
     int curBmpX=startx;
     for(int drawX=0;drawX<displayWidth;drawX++)
     {
        if(curBmpX>=boundDrawWidth)
          continue;
        
        //here it's safe to retrieve data
        int curPixel=bmp[curBmpY*wBmp+curBmpX];
        if(curPixel)
          digitalWrite(colPins[drawX],HIGH);
        else
          digitalWrite(colPins[drawX],LOW);  
          
        curBmpX++;
      }
      
     digitalWrite(rowPins[drawY],LOW);  //unmask the row 
     

     delay(1); //about 1/1000 frames per second? 
     digitalWrite(rowPins[drawY],HIGH); 
     
     curBmpY++;
   }   
}



char* createNewBmp(int w,int h){
  char*bmp= (char*)malloc(w*h);
  for(int i=0;i<w*h;i++)
    bmp[i]=0;
  return bmp;
}

void freeBmp(char* bmp){
  free(bmp); 
}

void setPixel(char *bmp,int wBmp,int hBmp,int x,int y,char color){
   if(x>=wBmp || y>=hBmp){
     //out of bound not set
    return; 
   }
   bmp[y*wBmp+x]=color;
}

void add5x5CharacterToBitmap(char* bmp,int wBmp,int hBmp,int pos,char character[][5],int spacer)
{
   int startx=(spacer+5)*pos;
   
   for(int y=0;y<5;y++)
     for(int x=0;x<5;x++)
      {
        setPixel(bmp,wBmp,hBmp,startx+x,y,character[y][x]); 
      }
   
}

//SUBPROGRAMS

void showEachLED(){
  //set all row to high;
  
  for(int x=0;x<NROWS;x++)
    digitalWrite(rowPins[x],HIGH);
 
  
  for(int x=0;x<NROWS;x++)
  {
   //set row low
   digitalWrite(rowPins[x],LOW);
   for(int y=0;y<NCOLS;y++)
   {
      digitalWrite(colPins[y],HIGH);
      delay(10); //display for half a sec.
      digitalWrite(colPins[y],LOW);      
   }
   
  //set row back to High
  digitalWrite(rowPins[x],HIGH);
  }
}

char MIT[]={
  1,0,1,0,1,1,1,1,
  1,1,1,0,1,0,1,0,
  1,0,1,0,1,0,1,0,
  1,0,1,0,1,0,1,0,
  1,0,1,0,1,0,1,0
};


 int albertBitmapWidth;
 int albertBitmapHeight;
 char* albertBitmap;

void initAlbertBitmap()
{
   albertBitmapWidth=10*6;
  albertBitmapHeight=5;
 albertBitmap=createNewBmp(albertBitmapWidth,albertBitmapHeight);
 add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,0,A5x5,1);
 add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,1,L5x5,1);
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,2,B5x5,1);  
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,3,E5x5,1); 
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,4,R5x5,1); 
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,5,T5x5,1);  
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,6,At5x5,1);  
    add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,7,M5x5,1); 
   add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,8,I5x5,1);  
   add5x5CharacterToBitmap(albertBitmap,albertBitmapWidth,albertBitmapHeight,9,T5x5,1); 
}


//MAIN PROGRAM

void setup()
{
  for(int i=0;i<NROWS;i++)
    pinMode(rowPins[i],OUTPUT);
   
  for(int i=0;i<NCOLS;i++)
    pinMode(colPins[i],OUTPUT);
    
  initAlbertBitmap(); 
}



int curDrawX=0;

#define LONGTIME 200
#define SHORTTIME 50

void loop()
{
    if(SHOWMODE==SHOWEACHLED){
     
      showEachLED();
    }
    else if(SHOWMODE==SHOWMIT){
        updateDisplay(MIT,0,0,8,5,8,5);
    }
    else if(SHOWMODE==SHOWALBERTATMIT){
    
      int loopTime=0;
      
      if(curDrawX==albertBitmapWidth-NCOLS-1)
        loopTime=LONGTIME;
      else if(curDrawX==0 || curDrawX==albertBitmapWidth-NCOLS)
      {
       curDrawX=0;
       loopTime=LONGTIME;
      }
      else
        loopTime=SHORTTIME;
       
      
     
      for(int i=0;i<loopTime;i++)
         updateDisplay(albertBitmap,curDrawX,0,albertBitmapWidth,albertBitmapHeight,albertBitmapWidth,albertBitmapHeight);
      
      
      curDrawX++;
    }
    
}
