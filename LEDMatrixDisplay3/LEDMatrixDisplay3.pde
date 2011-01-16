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





int rowPins[]={A2,8,6,4,2,A1};
int colPins[]={A0,3,5,7,9,10,11,12};


#define MIN(x,y) ((x<y)?(x):(y))
#define MAX(x,y) ((x>y)?(x):(y))

#define NROWS 6
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



char L5x5[]={
  1,0,0,0,0,
  1,0,0,0,0,
  1,0,0,0,0,
 1,0,0,0,0,
  1,1,1,1,1
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

char Unknown5x5[]={
  1,1,1,1,1,
  1,1,0,1,1,
  1,0,1,0,1,
  1,1,0,1,1,
  1,1,1,1,1 
};


Bitmap A5x5bm(5,5,(char*)A5x5);
Bitmap L5x5bm(5,5,(char*)L5x5);
Bitmap B5x5bm(5,5,(char*)B5x5);
Bitmap E5x5bm(5,5,(char*)E5x5);
Bitmap R5x5bm(5,5,(char*)R5x5);
Bitmap T5x5bm(5,5,(char*)T5x5);
Bitmap At5x5bm(5,5,(char*)At5x5);
Bitmap M5x5bm(5,5,(char*)M5x5);
Bitmap I5x5bm(5,5,(char*)I5x5);
Bitmap I3x5bm(3,5,(char*)I5x3);
Bitmap Unknown5x5bm(5,5,(char*)Unknown5x5);





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
     return L5x5bm;
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
     return I3x5bm
     ;
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
Bitmap *render;
void initAlbertBitmap()
{

   albertBitmap=new BitmapList();
   
  //albertBitmap=new Bitmap(1,1);
  /*A5x5bm.drawToBitmapExpand(albertBitmap,0,0);
  L5x5bm.drawToBitmapExpand(albertBitmap,6,0);
  B5x5bm.drawToBitmapExpand(albertBitmap,12,0);
  E5x5bm.drawToBitmapExpand(albertBitmap,18,0);  
   R5x5bm.drawToBitmapExpand(albertBitmap,24,0);   
   T5x5bm.drawToBitmapExpand(albertBitmap,30,0);
  At5x5bm.drawToBitmapExpand(albertBitmap,36,0);
   M5x5bm.drawToBitmapExpand(albertBitmap,42,0);
  I5x5bm.drawToBitmapExpand(albertBitmap,48,0);
  T5x5bm.drawToBitmapExpand(albertBitmap,54,0);*/
  //drawMessageToBitmap(albertBitmap,"ALBERT@MIT",0,0,1);
  drawMessageToBitmapList(albertBitmap,"ALBERT@MIT@ALBERT",0,0,1);
  
  Serial.print("width=");
  Serial.println(albertBitmap->getWidth());
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
  
  initAlbertBitmap(); 
  
  render=new Bitmap(NCOLS,NROWS);

}



int curDrawX=0;

#define LONGTIME 100
#define SHORTTIME 25



void loop()
{
    int loopTime=0;
    
    if(curDrawX==albertBitmap->getWidth()-NCOLS)
        loopTime=LONGTIME;
        
      else if(curDrawX==0 || curDrawX==albertBitmap->getWidth()-NCOLS+1)
      {
       curDrawX=0;
       loopTime=LONGTIME;
      }
      else
        loopTime=SHORTTIME;
    
    
    render->clear();
    albertBitmap->drawToBitmap(render,-curDrawX,0);
    
    for(int i=0;i<loopTime;i++)
       render->drawToDisplay(0,0,-1,-1,NCOLS,NROWS,rowPins,colPins);
    
    curDrawX++;
    
    
}
