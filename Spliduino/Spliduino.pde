/********

Copyright 2010 Wu Albert Cheng <albertwcheng@gmail.com>

LEDMatrixDisplay for Arduino

programmed to display message on LED matrix

******/

#include <stdlib.h>
#include <avr/pgmspace.h>

void * operator new(size_t size)
{
  return malloc(size);
}



void operator delete(void * ptr)
{
  free(ptr);
}




int buttonPin=13;

int rowPins[]={8,6,4,2,A1};
int colPins[]={A0,3,5,7,9,10,11,12};


#define MIN(x,y) ((x<y)?(x):(y))
#define MAX(x,y) ((x>y)?(x):(y))

#define NROWS 5
#define NCOLS 8

#define SHOWMIT   0
#define SHOWALBERTATMIT 1 
#define SHOWEACHLED  2
#define SHOWMODE  SHOWALBERTATMIT


//BITMAP LIBRARY:

class Bitmap{
  char *bmp;
  int wBmp;
  int hBmp; 
  int nofree;
  int curx;
  
  
  
  
  void recreate(int _wBmp,int _hBmp)
  {
    if(!nofree)
      free(bmp);
      
    wBmp=_wBmp;
    hBmp=_hBmp;
    bmp=(char*)malloc(_wBmp*_hBmp);
    for(int i=0;i<wBmp*hBmp;i++)
      bmp[i]=0;
   
    nofree=0;    
  }
  
  
  public:
  
  
  
  
  Bitmap(int _wBmp,int _hBmp){

    nofree=1;
    recreate(_wBmp,_hBmp);
    
  }
  ~Bitmap(){
    if(!nofree)
      free(bmp); 
  }
  Bitmap(int _wBmp,int _hBmp,char *_bmp){
    bmp=_bmp;
    wBmp=_wBmp;
    hBmp=_hBmp; 
    nofree=1;
  }
  
  void clear(){
     for(int i=0;i<wBmp*hBmp;i++)
      bmp[i]=0; 
  }
  
  int getPixel(int x,int y){
    if(x>=wBmp || y>=hBmp || x<0 || y<0)
      return 0;
    
    return bmp[y*wBmp+x]; 
  }
  
  void setPixel(int x,int y,int value){
    if(x>=wBmp || y>=hBmp || x<0 || y<0)
      return ;
     
    bmp[y*wBmp+x]=value;
  }
  
  void drawToBitmap(Bitmap* dest,int dstx,int dsty,int srcx=0,int srcy=0,int srcw=-1,int srch=-1)
  { 
     
     if(srcw==-1)
       srcw=wBmp-srcx;
     if(srch==-1)
       srch=hBmp-srch;
       
     for(int drawy=0;drawy<srch;drawy++)
       for(int drawx=0;drawx<srcw;drawx++)
         dest->setPixel(dstx+drawx,dsty+drawy,this->getPixel(srcx+drawx,srcy+drawy));
  } 
  
  void drawToBitmapExpand(Bitmap *dest,int dstx,int dsty,int srcx=0,int srcy=0,int srcw=-1,int srch=-1)
  {
    
    if(srcw==-1)
       srcw=wBmp-srcx;
     if(srch==-1)
       srch=hBmp-srch;
       
    int olddestWidth=dest->getWidth();
    int olddestHeight=dest->getHeight();
    int newReqWidth=dstx+srcw;
    int newReqHeight=dsty+srch;
    
    if(newReqWidth>olddestWidth || newReqHeight>olddestHeight)
    { //need to expand!
       int newDestWidth=MAX(olddestWidth,newReqWidth);
       int newDestHeight=MAX(olddestHeight,newReqHeight);
       dest->nofree=1; //take over the old dest bmp
       char *oldDestBitmapData=dest->bmp;
       dest->recreate(newDestWidth,newDestHeight);
       Bitmap tmpOldDestBitmap(olddestWidth,olddestHeight,oldDestBitmapData);
       tmpOldDestBitmap.drawToBitmap(dest,0,0);
       free( oldDestBitmapData); //free old dest bmp data       
      
       
        
    }  
    
     //now draw this bitmap
    this->drawToBitmap(dest,dstx,dsty,srcx,srcy,srcw,srch);
  }
  
  int getWidth()
  {
    return wBmp; 
  }

  int getHeight()
  {
    return hBmp;
  }  
  
  void drawToDisplay(int startx,int starty,int widthDraw,int heightDraw,int displayWidth,int displayHeight,int *rowPins,int *colPins)
  {
   
    if(widthDraw<0)
      widthDraw=wBmp;
    if(heightDraw<0)
     heightDraw=hBmp;    
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
  
  
};


char A5x5[]={
  0,0,1,0,0,
  0,1,0,1,0,
  1,1,1,1,1,
  1,0,0,0,1,
  1,0,0,0,1  
};

char _1[]={
  0,1,0,
  1,1,0,
  0,1,0,
  0,1,0,
  1,1,1  
};

char _2[]={
  0,1,1,0,
  1,0,0,1,
  0,0,1,0,
  0,1,0,0,
  1,1,1,1
  
};

char _3[]={
  0,1,1,0,
  1,0,0,1,
  0,0,1,0,
  1,0,0,1,
  0,1,1,0
  
};

char _4[]={
  0,0,0,1,
  0,0,1,1,
  0,1,0,1,
  1,1,1,1,
  0,0,0,1
  
};

char _5[]={
   1,1,1,1,
   1,0,0,0,
   1,1,1,0,
   0,0,0,1,
   1,1,1,0 
};

char _6[]={
  0,0,1,1,
  0,1,0,0,
  1,1,1,0,
  1,0,0,1,
  0,1,1,0
  
};

char _7[]={
  1,1,1,1,
  0,0,0,1,
  0,0,1,0,
  0,0,1,0,
  0,1,0,0
};

char _8[]={
  0,1,1,0,
  1,0,0,1,
  0,1,1,0,
  1,0,0,1,
  0,1,1,0
};

char _9[]={
  0,1,1,0,
  1,0,0,1,
  0,1,1,1,
  0,0,1,0,
  0,1,0,0
};

char _0[]={
  0,1,1,0,
  1,0,0,1,
  1,0,0,1,
  1,0,0,1,
  0,1,1,0
  
};

char L5x4[]={
  1,0,0,0,
  1,0,0,0,
  1,0,0,0,
 1,0,0,0,
  1,1,1,1
};

char B5x5[]={
  1,1,1,1,0,
  1,0,0,0,1,
  1,1,1,1,0,
  1,0,0,0,1,
  1,1,1,1,0
};

char E5x5[]={
  1,1,1,1,1,
  1,0,0,0,0,
  1,1,1,1,1,
  1,0,0,0,0,
  1,1,1,1,1 
};

char R5x5[]={
  1,1,1,1,0,
  1,0,0,0,1,
  1,1,1,1,0,
  1,0,0,1,0,
  1,0,0,0,1 
  
};

char T5x5[]={
  1,1,1,1,1,
  0,0,1,0,0,
  0,0,1,0,0,
  0,0,1,0,0,
  0,0,1,0,0 
};

char At5x5[]={
  1,1,1,1,1,
  1,0,1,0,1,
  1,0,1,1,1,
  1,0,0,0,0,
  1,1,1,1,1 
};

char M5x5[]={
  1,0,0,0,1,
  1,1,0,1,1,
  1,0,1,0,1,
  1,0,0,0,1,
  1,0,0,0,1 
};

char S5x5[]={
  0,1,1,1,1,
  1,0,0,0,0,
  0,1,1,1,0,
  0,0,0,0,1,
  1,1,1,1,0 
};

char P5x5[]={
  1,1,1,1,0,
  1,0,0,0,1,
  1,1,1,1,0,
  1,0,0,0,0,
  1,0,0,0,0 
};

char D5x5[]={
  1,1,1,0,0,
  1,0,0,1,0,
  1,0,0,0,1,
  1,0,0,1,0,
  1,1,1,0,0 
};
char C5x5[]={
  0,1,1,1,0,
  1,0,0,0,1,
  1,0,0,0,0,
  1,0,0,0,1,
  0,1,1,1,0 
};

char N5x5[]={
  1,0,0,0,1,
  1,1,0,0,1,
  1,0,1,0,1,
  1,0,0,1,1,
  1,0,0,0,1 
};

char G5x5[]={
  0,1,1,1,1,
  1,0,0,0,0,
  1,0,1,1,1,
  1,0,0,1,0,
  0,1,1,1,0 
};

char I5x5[]={
  0,1,1,1,0,
  0,0,1,0,0,
  0,0,1,0,0,
  0,0,1,0,0,
  0,1,1,1,0 
};

char I5x3[]={
  1,1,1,
  0,1,0,
  0,1,0,
  0,1,0,
  1,1,1,
};

char eq5x4[]={
  0,0,0,0,
  1,1,1,1,
  0,0,0,0,
  1,1,1,1,
  0,0,0,0 
  
};

char dot[]={
  0,0,0,
  0,0,0,
  0,0,0,
  0,0,0,
  0,1,0
};

char psi[]={
  1,0,1,0,1,
  1,0,1,0,1,
  0,1,1,1,1,
  0,0,1,0,0,
  0,1,1,1,0
  
};

Bitmap eqbm(4,5,(char*)eq5x4);
Bitmap dotbm(3,5,(char*)dot);
Bitmap psibm(5,5,(char*)psi);

char Unknown5x5[]={
  1,1,1,1,1,
  1,1,0,1,1,
  1,0,1,0,1,
  1,1,0,1,1,
  1,1,1,1,1 
};

char SE5x16[]={
 0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,
 0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,
 1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,
 1,1,1,0,0,0,1,0,0,1,0,0,0,1,1,1,
 1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1
};

char ExE[]={

 1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,
 1,1,1,0,0,0,1,0,0,1,0,0,0,1,1,1,
 1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,
 0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,
 0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0
};


Bitmap A5x5bm(5,5,(char*)A5x5);
Bitmap L4x5bm(4,5,(char*)L5x4);
Bitmap B5x5bm(5,5,(char*)B5x5);
Bitmap E5x5bm(5,5,(char*)E5x5);
Bitmap R5x5bm(5,5,(char*)R5x5);
Bitmap T5x5bm(5,5,(char*)T5x5);
Bitmap At5x5bm(5,5,(char*)At5x5);
Bitmap M5x5bm(5,5,(char*)M5x5);
Bitmap I5x5bm(5,5,(char*)I5x5);
Bitmap I3x5bm(3,5,(char*)I5x3);
Bitmap S5x5bm(5,5,(char*)S5x5);
Bitmap P5x5bm(5,5,(char*)P5x5);
Bitmap D5x5bm(5,5,(char*)D5x5);
Bitmap C5x5bm(5,5,(char*)C5x5);
Bitmap N5x5bm(5,5,(char*)N5x5);
Bitmap G5x5bm(5,5,(char*)G5x5);
Bitmap Unknown5x5bm(5,5,(char*)Unknown5x5);
Bitmap SEbm(16,5,(char*)SE5x16);
Bitmap ExEbm(16,5,(char*)ExE);


Bitmap _0bm(4,5,(char*)_0);
Bitmap _1bm(3,5,(char*)_1);
Bitmap _2bm(4,5,(char*)_2);
Bitmap _3bm(4,5,(char*)_3);
Bitmap _4bm(4,5,(char*)_4);
Bitmap _5bm(4,5,(char*)_5);
Bitmap _6bm(4,5,(char*)_6);
Bitmap _7bm(4,5,(char*)_7);
Bitmap _8bm(4,5,(char*)_8);
Bitmap _9bm(4,5,(char*)_9);

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

char arrow[]={
  0,0,0,0,1,0,0,0,
  0,1,1,1,1,1,0,0,
  0,1,1,1,1,1,1,0,
  0,1,1,1,1,1,0,0,
  0,0,0,0,1,0,0,0
};


Bitmap arrowbm(8,5,(char*)arrow);


class BitmapPtr{
  public:
   Bitmap* ptr;
  
  void operator=(Bitmap* _ptr)
  {
    ptr=_ptr;
  }
  operator Bitmap*()
  {
    return ptr; 
  }
  
  Bitmap* operator->(){
    return ptr; 
  }
  
  BitmapPtr(){}
  ~BitmapPtr(){}
};

Bitmap& getCharBitmap(char c){
  switch(c){
   case 'A':
     return A5x5bm;
   case 'B':
     return B5x5bm;
   case 'L':
     return L4x5bm;
   case 'E':
     return E5x5bm;
   case 'R':
     return R5x5bm;
   case 'T':
      return T5x5bm;
    case '@':
      return At5x5bm;
    case 'M':
      return M5x5bm;
    case 'I':
     return I3x5bm;
    case 'S':
     return S5x5bm;
         case 'C':
     return C5x5bm;
         case 'N':
     return N5x5bm;
         case 'G':
     return G5x5bm;
         case 'P':
     return P5x5bm;
         case 'D':
     return D5x5bm;
     
    case '1':
      return _1bm;
    case '2':
     return _2bm;
     case '3':
      return _3bm;
      case '4':
      return _4bm;
      case '5':
      return _5bm;
      case '6':
      return _6bm;
      case '7':
      return _7bm;
      case '8':
      return _8bm;
      case '9':
      return _9bm;
      case '0':
      return _0bm;
      case '.':
       return dotbm;
       case 'p':
        return psibm;
        case '=':
        return eqbm;
   default:
     return Unknown5x5bm;  
   } 
}

void drawMessageToBitmap(void* dest,const char* msg,int startx,int starty,int spacer)
{
  
  int len=strlen(msg);
  
  Serial.println(len);
  int curx=startx;
  for(int i=0;i<len;i++)
  {
     char c=msg[i];
     Bitmap& charBitmap=getCharBitmap(c);
     charBitmap.drawToBitmapExpand((Bitmap*)dest,curx,starty);
     curx+=spacer+charBitmap.getWidth();
  }
}


class BitmapNode{
  public:
  
  BitmapNode* prev;
  BitmapNode* next;
  Bitmap* bitmap;  
  int x;
  int y;
  int clipw;
  int cliph;
  BitmapNode(Bitmap* _bitmap,int _x,int _y,int _clipw=-1,int _cliph=-1):bitmap(_bitmap),prev(NULL),next(NULL),x(_x),y(_y),clipw(_clipw),cliph(_cliph){}
  bool isInDrawArea(){
    return true; //for now; 
  }
   
  
};

class BitmapList{
  BitmapNode *head;
  BitmapNode *tail;
  int wBmp;
  int hBmp;
  public:
  BitmapList():head(NULL),tail(NULL),wBmp(0),hBmp(0){}
 ~BitmapList(){
   BitmapNode* curNode;
   curNode=head;
  while(curNode){
    BitmapNode* nextNode=curNode->next;
    delete curNode;
    curNode=nextNode;
  } 
 }
 int getWidth(){
   return wBmp; 
 }
 int getHeight(){
   return hBmp; 
 }
  void appendBitmap(Bitmap* _bitmap,int _x,int _y,int _clipw=-1,int _cliph=-1)
  {
    
    BitmapNode *newBitmapNode=new BitmapNode(_bitmap,_x,_y,_clipw,_cliph);
    
    int newBitmapWidth=_bitmap->getWidth();
    int newBitmapHeight=_bitmap->getHeight();
    
    wBmp=MAX(_x+newBitmapWidth,wBmp);
    hBmp=MAX(_y+newBitmapHeight,hBmp);
    
    if(!head){
      //list is empty
      head=newBitmapNode;
      tail=head;
      return;
    }
    
    if(!head->next){
      //a one member list
      tail= newBitmapNode;
      tail->prev=head;
      head->next=tail;
      return; 
    }
    
    
    BitmapNode *oldTail=tail;
    tail= newBitmapNode;
    tail->prev=oldTail;
    oldTail->next=tail;
    
  }
  
  
  void drawToBitmap(Bitmap* dest,int dstx,int dsty)
  { 
     BitmapNode *cur=head;
     while(cur!=NULL)
     {
       if(cur->isInDrawArea())
         cur->bitmap->drawToBitmap(dest,dstx+cur->x,dsty+cur->y);
       cur=cur->next; 
     }
    
  } 
};

void drawMessageToBitmapList(void* _dest,const char* msg,int startx,int starty,int spacer)
{
  
  BitmapList *dest=(BitmapList*)_dest;
  
  int len=strlen(msg);
  
  //Serial.println(len);
  int curx=startx;
  for(int i=0;i<len;i++)
  {
     char c=msg[i];
     Bitmap& charBitmap=getCharBitmap(c);
     //charBitmap.drawToBitmapExpand((Bitmap*)dest,curx,starty);
     dest->appendBitmap(&charBitmap,curx,starty);
     curx+=spacer+charBitmap.getWidth();
  }
}

BitmapList* albertBitmap;
BitmapList* splidarSplash;
BitmapList* currentNumberBitmap=NULL;
BitmapList* result=NULL;

Bitmap *render;
void initAlbertBitmap()
{

   albertBitmap=new BitmapList();

  drawMessageToBitmapList(albertBitmap,"ALBERT@MIT@ALBERT",0,0,1);
  
  Serial.print("width=");
  Serial.println(albertBitmap->getWidth());
}

void initSplidarSplash()
{
  splidarSplash=new BitmapList();
 
  drawMessageToBitmapList(splidarSplash,"SPLICING",0,0,1); 
}


//MAIN PROGRAM

void setup()
{
  for(int i=0;i<NROWS;i++)
    pinMode(rowPins[i],OUTPUT);
   
  for(int i=0;i<NCOLS;i++)
    pinMode(colPins[i],OUTPUT);
   Serial.begin(9600);
  Serial.println("Ready");
  
  initSplidarSplash(); 
  
  render=new Bitmap(NCOLS,NROWS);
  
  pinMode(buttonPin,INPUT);
}



int curDrawX=0;

#define LONGTIME 100
#define SHORTTIME 25

class ButtonHandler{
  private:
    int pin;
      int buttonN;
      int startMilli;
    public:
  ButtonHandler(int _pin){
     pin=_pin;
     buttonN=0;
     pinMode(pin,INPUT);
     startMilli=-1;
   }
   

 int getButtonOnTime(){
    if(startMilli<0){
      return -1;
      
    } 
    return millis()-startMilli;
 }
  
  void resetButton(){
    startMilli=-1;  
  }
  
  int buttonPressed(){ //button was pressed and released
    //return digitalRead(pin); 
    int rea=digitalRead(pin);
    if(rea){
      buttonN++; 
    }else{
      buttonN=0;
      //startMilli=-1;
    } 
    
    if(buttonN==1){
       startMilli=millis();
    }
    
    if(startMilli>0 && buttonN==0){
      int timeElapsed=millis()-startMilli;
      startMilli=-1;
      return timeElapsed;
    }
    
    return -1;

  }
  

  
};

ButtonHandler button(buttonPin);


bool SplidarSplash()
{
    int loopTime=0;
    
    if(curDrawX==splidarSplash->getWidth()-NCOLS)
        loopTime=LONGTIME;
        
      else if(curDrawX==0 || curDrawX==splidarSplash->getWidth()-NCOLS+1)
      {
       curDrawX=0;
       loopTime=LONGTIME;
      }
      else
        loopTime=SHORTTIME;
    
    
    render->clear();
    splidarSplash->drawToBitmap(render,-curDrawX,0);
    
    for(int i=0;i<loopTime;i++){
       
       if(button.buttonPressed()>=0){
         curDrawX=0;
         return false; 
       }
       render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    }
    
    curDrawX++; 
    
    return true;
    
}

int episode=0;

int UIJ=0;
int IE=0;
int DIJ=0;
int EJ=0;
double psivalue;
char buff[10];

bool showResult()
{
    int loopTime=0;
    
    if(!result)
    {
          result=new BitmapList();
    dtostrf(psivalue,3,3,buff);
    char buff2[50];
    sprintf(buff2,"p=%s",buff);
    Serial.print("write to LED:");
    Serial.println(buff2);
    drawMessageToBitmapList(result,buff2,0,0,1); 

    }
    
    if(curDrawX==result->getWidth()-NCOLS)
        loopTime=LONGTIME;
        
      else if(curDrawX==0 || curDrawX==result->getWidth()-NCOLS+1)
      {
       curDrawX=0;
       loopTime=LONGTIME;
      }
      else
        loopTime=SHORTTIME;
    
    
    render->clear();
    result->drawToBitmap(render,-curDrawX,0);
    
    for(int i=0;i<loopTime;i++){
       
       if(button.buttonPressed()>=0){
         curDrawX=0;
         return false; 
       }
       render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    }
    
    curDrawX++; 
    
    return true;
    
}


bool showSE()
{
    int loopTime=0;
    
    if(curDrawX==SEbm.getWidth()-NCOLS)
        loopTime=LONGTIME;
        
      else if(curDrawX==0 || curDrawX==SEbm.getWidth()-NCOLS+1)
      {
       curDrawX=0;
       loopTime=LONGTIME;
      }
      else
        loopTime=SHORTTIME;
    
    
    render->clear();
    SEbm.drawToBitmap(render,-curDrawX,0);
    
    for(int i=0;i<loopTime;i++){
       
       if(button.buttonPressed()>=0){
         curDrawX=0;
         return false; 
       }
       render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    }
    
    curDrawX++; 
    
    return true;
    
}

bool showSE1()
{
    render->clear();
    SEbm.drawToBitmap(render,0,0);
    if(button.buttonPressed()>=0)
      return false;
    render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    
}

bool showSE2()
{
    render->clear();
    SEbm.drawToBitmap(render,-4,0);
    if(button.buttonPressed()>=0)
      return false;
    render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    
}

bool showSE3()
{
    render->clear();
    SEbm.drawToBitmap(render,-8,0);
    if(button.buttonPressed()>=0)
      return false;
    render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    
}

bool showSE4()
{
    render->clear();
    ExEbm.drawToBitmap(render,-4,0);
    if(button.buttonPressed()>=0)
      return false;
    render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    
}



int curNumber=0;

bool getNumber()
{
 
if(currentNumberBitmap==NULL){
   currentNumberBitmap=new BitmapList();
  sprintf(buff,"%d",curNumber);
  Serial.print("updating number to ");
  Serial.println(buff);
  drawMessageToBitmapList(currentNumberBitmap,buff,0,0,0); 
  }
  

  
  int loopTime=0;
  
  if(currentNumberBitmap->getWidth()<NCOLS){
    curDrawX=0;
  }
  
  if(curDrawX==currentNumberBitmap->getWidth()-NCOLS)
        loopTime=SHORTTIME;
    
   else if(curDrawX==0 || curDrawX==currentNumberBitmap->getWidth()-NCOLS+1)
   {
       curDrawX=0;
       loopTime=SHORTTIME;
   }
   else
        loopTime=SHORTTIME;
  int pressTime;
  
  
  render->clear();
  currentNumberBitmap->drawToBitmap(render,-curDrawX,0);
  
   for(int i=0;i<loopTime;i++){
       pressTime=button.buttonPressed();
       
       if(button.getButtonOnTime()>500){
          render->clear();
          arrowbm.drawToBitmap(render,0,0);
          render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
       }
       
       if(pressTime>=0){
         
         
        Serial.println("buttonpressed");
        delete currentNumberBitmap;
        currentNumberBitmap=NULL;
         curDrawX=0;
        if(pressTime>500){
           Serial.println("presstime>500");
           return false;   
         }
         
         curNumber++;
       
         
       }
       render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    }
   
   curDrawX++; 
   
   
   return true;
}



void loop()
{
  switch(episode){
    case 0:
    if (!SplidarSplash()){
      //button pressed exit this stage 
      episode=1;
      delete splidarSplash;
    }
    break;
    case 1:
    if (!showSE()){
      episode=2;
       
    }
    break;
    case 2:
    if(!showSE1()){
      //currentNumberBitmap=NULL;
      episode=3; 
    }
    break;
    case 3:
    
    if(!getNumber()){
      episode=4; 
          UIJ=curNumber;
    curNumber=0;
    }
    

    break;
    case 4:
    if(!showSE2()){
      //currentNumberBitmap=NULL;
      episode=5; 
    }
    break; 
    
    case 5:
    
    if(!getNumber()){
      episode=6; 
          IE=curNumber;
    curNumber=0;
    }
    

    break;    

    case 6:
    if(!showSE3()){
      //currentNumberBitmap=NULL;
      episode=7; 
    }
    break; 
    
    case 7:
    
    if(!getNumber()){
      episode=8; 
          DIJ=curNumber;
    curNumber=0;
    }
    
  
    break;       
    case 8:
    if(!showSE4()){
      episode=9; 
    }
   break;
     
    case 9:
    
    if(!getNumber()){
      episode=10; 
          EJ=curNumber;
    curNumber=0;
    double ID=(IE+UIJ+DIJ);
    double ED=(EJ);
    psivalue=ID/(ID+ED);
    Serial.print("psi=");
    Serial.println(psivalue);
}
    
  
    break;   
   
   case 10:
   showResult(); 
   
    default:
    break;
  }
}
