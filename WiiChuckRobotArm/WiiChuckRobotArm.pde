#include <Wire.h>
#include <string.h>

#undef int
#include <stdio.h>

uint8_t outbuf[6];		// array to store arduino output
int cnt = 0;
int ledPin = 13;

void
setup ()
{
  Serial.begin (19200);
  Serial.print ("Finished setup\n");
  Wire.begin ();		// join i2c bus with address 0x52
  nunchuck_init (); // send the initilization handshake
  setup_robotArm();
}

void
nunchuck_init ()
{
  Wire.beginTransmission(0x52);	// device address
  Wire.send(0xF0);		        // 1st initialisation register
  Wire.send(0x55);		        // 1st initialisation value
  Wire.endTransmission();
  //delay(1);
  Wire.beginTransmission(0x52);
  Wire.send(0xFB);		        // 2nd initialisation register
  Wire.send(0x00);		        // 2nd initialisation value
  Wire.endTransmission();

  return;

  Wire.beginTransmission (0x52);	// transmit to device 0x52
  Wire.send (0x40);		// sends memory address
  Wire.send (0x00);		// sends sent a zero.  
  Wire.endTransmission ();	// stop transmitting
}

void
send_zero ()
{
  Wire.beginTransmission (0x52);	// transmit to device 0x52
  Wire.send (0x00);		// sends one byte
  Wire.endTransmission ();	// stop transmitting
}

void
loop ()
{
  Wire.requestFrom (0x52, 6);	// request data from nunchuck
  while (Wire.available ())
  {
    outbuf[cnt] = nunchuk_decode_byte (Wire.receive ());	// receive byte as an integer
    digitalWrite (ledPin, HIGH);	// sets the LED on
    cnt++;
  }

  // If we recieved the 6 bytes, then go print them
  if (cnt >= 5)
  {
    print ();
  }

  cnt = 0;
  send_zero (); // send the request for next bytes
  delay (100);
}

// Print the input data we have recieved
// accel data is 10 bits long
// so we read 8 bits, then we have to add
// on the last 2 bits.  That is why I
// multiply them by 2 * 2
void
print ()
{
  int joy_x_axis = outbuf[0];
  int joy_y_axis = outbuf[1];
  int accel_x_axis = outbuf[2] * 2 * 2; 
  int accel_y_axis = outbuf[3] * 2 * 2;
  int accel_z_axis = outbuf[4] * 2 * 2;

  int z_button = 0;
  int c_button = 0;

  // byte outbuf[5] contains bits for z and c buttons
  // it also contains the least significant bits for the accelerometer data
  // so we have to check each bit of byte outbuf[5]
  if ((outbuf[5] >> 0) & 1)
  {
    z_button = 1;
  }
  if ((outbuf[5] >> 1) & 1)
  {
    c_button = 1;
  }

  if ((outbuf[5] >> 2) & 1)
  {
    accel_x_axis += 2;
  }
  if ((outbuf[5] >> 3) & 1)
  {
    accel_x_axis += 1;
  }

  if ((outbuf[5] >> 4) & 1)
  {
    accel_y_axis += 2;
  }
  if ((outbuf[5] >> 5) & 1)
  {
    accel_y_axis += 1;
  }

  if ((outbuf[5] >> 6) & 1)
  {
    accel_z_axis += 2;
  }
  if ((outbuf[5] >> 7) & 1)
  {
    accel_z_axis += 1;
  }

  Serial.print (joy_x_axis, DEC);
  Serial.print ("\t");

  Serial.print (joy_y_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_x_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_y_axis, DEC);
  Serial.print ("\t");

  Serial.print (accel_z_axis, DEC);
  Serial.print ("\t");

  Serial.print (z_button, DEC);
  Serial.print ("\t");

  Serial.print (c_button, DEC);
  Serial.print ("\t");

  Serial.print ("\r\n");



  for(int i=0;i<=12;i++){
    digitalWrite(i,LOW); 
  }

  if(joy_x_axis<80){
    //rotate left
    digitalWrite(10,HIGH);
  }
  else if(joy_x_axis>190){
    //rotate right
    digitalWrite(11,HIGH); 
  }

  //return;

  int zbtn_down=0;
  int cbtn_down=0;

  if(z_button==1){
    if(c_button==0){
      //"c" down"
      cbtn_down=1; 
    }
  }
  else{
    //z_button==0
    if(c_button==1){
      cbtn_down=1;
      zbtn_down=1;
    } 
    else{
      zbtn_down=1; 
    }
  }


  int yOpt;

  if(joy_y_axis<80){
    yOpt=-1; 
  }
  else if(joy_y_axis>190){
    yOpt=1; 
  }
  else{
    yOpt=0; 
  }

  if(cbtn_down){
    //cbtn_down
    if(zbtn_down){
      //both down, operate grip
      //up=>open
      if(yOpt==1){
        //open
        digitalWrite(6,HIGH);
      }
      else if(yOpt==-1){
        digitalWrite(7,HIGH);
      }
    }
    else{
      //only cdown
      if(yOpt==1){

        digitalWrite(9,HIGH);
      }
      else if(yOpt==-1){
        digitalWrite(8,HIGH);
      }     

    }

  }
  else{
    //cbtn not down


    if(zbtn_down){
      //zbtn down
      //4,5
      if(yOpt==1){
        digitalWrite(5,HIGH);
      }
      else if(yOpt==-1){
        digitalWrite(4,HIGH); 
      }
    }
    else{
      //zbtn not down
      //Lower 2,3
      if(yOpt==1){
        digitalWrite(2,HIGH);
      }
      else if(yOpt==-1){
        digitalWrite(3,HIGH); 
      }
    } 
  }

  delay(20);
  for(int i=2;i<=12;i++){
    digitalWrite(i,LOW); 
  }

}

// Encode data to format that most wiimote drivers except
// only needed if you use one of the regular wiimote drivers
unsigned char
nunchuk_decode_byte (unsigned char x)
{
  x = (x ^ 0x17) + 0x17;
  return x;
}


void setup_robotArm(){

  for(int i=2;i<=12;i++){
    pinMode(i,OUTPUT);
    digitalWrite(i,LOW); 
  }



}

void on_one_motor(int x){
  for(int i=2;i<=11;i++){
    digitalWrite(i,LOW); 
  }

  digitalWrite(x,HIGH);
}

void demoLoop(){
  for(int i=2;i<=12;i++){
    digitalWrite(i,HIGH);
    delay(200);
    digitalWrite(i,LOW);
    delay(500); 
  }

  delay(5000); 
}

void resetArm()
{
  for(int i=2;i<=11;i++){
    pinMode(i,OUTPUT);
    digitalWrite(i,LOW); 
  }

  digitalWrite(2,HIGH); 
  delay(5000); 
  digitalWrite(5,HIGH);
  delay(5000); 
  digitalWrite(6,HIGH);
  delay(5000); 
  digitalWrite(9,HIGH); 
  delay(5000); 
  digitalWrite(11,HIGH); 

  delay(5000); 
}

void resetArmOtherWay()
{
  for(int i=2;i<=11;i++){
    pinMode(i,OUTPUT);
    digitalWrite(i,LOW); 
  }

  digitalWrite(3,HIGH); 

  delay(5000); 
  digitalWrite(3,LOW);
  digitalWrite(4,HIGH);
  delay(5000); 
  digitalWrite(4,LOW);
  digitalWrite(7,HIGH);
  delay(5000); 
  digitalWrite(7,LOW);
  digitalWrite(8,HIGH); 
  delay(5000); 
  digitalWrite(8,LOW);
  digitalWrite(10,HIGH); 

  delay(5000); 
}

//void loop(){

//resetArmOtherWay();
//on_one_motor(4);
// demoLoop();
// delay(10000);
//}

