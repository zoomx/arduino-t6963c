#include "T6963.h"
#include <Wire.h>          // I2C Bus Library DS1307,DS3231
#include <DS1307.h>
#include <OneWire.h>       // One Wire Library DS1820 Temp Sensor
#include <DallasTemperature.h>
#include "Harddisc__30.h" //Digital Clock Font
#include "GLCD_Clock.h"   //Analog Clock Picture


T6963 LCD(240,64,6,32);// 240x64 Pixel and 6x8 Font



// Data wire DS1820 one Wire is plugged into port 11 on the Arduino
#define ONE_WIRE_BUS 11

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);
char tVal[6];

// Clock init. 
char strclock[26];
char* Month[] = { 0, "Januar", "Februar", "Maerz", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" };// Monat
int sec, pcount, state=0, HR_circle, MIN_circle, SEC_circle;
String inByte;

// Set Realtime Clock with buildin Serial Monitor
void setclock()
     {
     RTC.stop(); // start set clock 
     inByte="";
     
     while (Serial.available()) { 
	  delay(10); 
      if ( Serial.available()>0)
         {
         char c = Serial.read();
         inByte += c;
         }} 
            
    if (inByte.length() >0) {
          
      char this_char[inByte.length() + 1]; // convert String to int
      inByte.toCharArray(this_char, sizeof(this_char));
      int num = atoi(this_char);          // End convert String to int
      
      switch (state) {
    case 1:
      RTC.set(DS1307_SEC,num);        //set the seconds 0-59
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the minutes 0-59 : ");
      state=2;
      break;
    case 2:
      RTC.set(DS1307_MIN,num);     //set the minutes 0-59
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the hours 1-23 : ");
      state=3;
      break;
    case 3:
      RTC.set(DS1307_HR,num);       //set the hours 1-23 
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the day of the week 1-7 Sunday-Saturday : ");
      state=4;
      break;
    case 4:
      RTC.set(DS1307_DOW,num);       //set the day of the week 1-7 Sunday-Saturday
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the date 1-28/29/30/31 : ");
      state=5;
      break;
    case 5:
      RTC.set(DS1307_DATE,num);       //set the date 1-28/29/30/31
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the month 1-12 : ");
      state=6;
      break;
    case 6:
      RTC.set(DS1307_MTH,num);        //set the month 1-12
      Serial.println(num); //
      clock_main();
      Serial.print("Please set the year 0-99 : ");
      state=7;
      break;
    case 7:
      RTC.set(DS1307_YR,num);         //set the year 0-99
      Serial.println(num); //
      clock_main();
      Serial.print("all done.");
      RTC.start(); //end set clock
      state=0;
      break;
          
    default: ;
      // if nothing else matches, do the default
      // default is optional
  }
 }
}
// Dayweek line
void dayofweek(int x, int y) //Day of the Week x,y
      {
      int offset=3;    //Offset Position Cursor
      LCD.TextGoTo(x,y);
      LCD.writeString("So Mo Di Mi Do Fr Sa");
      int dow=(RTC.get(DS1307_DOW,true)-1)*offset;
      LCD.drawrectbyte((x+dow)*LCD.getFw(),y,8,2,0b111111); // draw dayweek Cursor
      }
      
      
      
// Digital Clock
void digital_clock(int x, int y, int TimeZone) //Position x, Position y, Set TimeZone
      {
      sprintf(strclock, "%2.2d:%2.2d:%2.2d", RTC.get(DS1307_HR,false)+TimeZone, RTC.get(DS1307_MIN,false), RTC.get(DS1307_SEC,false)); //Anzeigeformat Uhrzeit
      LCD.glcd_print2_P( x, y, (strclock), &Harddisc__30,0);
      }
      
      
      
//  Day Month Year line     
void daymonthyear(int x, int y) //Day Month Year x,y
      {
      int size = 0 ;  
      sprintf(strclock, "%2.2d.%s.%4.4d", RTC.get(DS1307_DATE,false), Month[RTC.get(DS1307_MTH,false)],RTC.get(DS1307_YR,false)); //Anzeigeformat Monat und Datum
      size = strlen(strclock);
      LCD.TextGoTo(x-size,y);
      LCD.writeString(strclock);
      } 

/*
	Draw clock hands
	Parameter: x, y: center radius start angle, end angle. 0 = Top, 90=right clockwise, color 1=on 0=off
*/
void analog_clock(int x, int y, int radius, int angle_start, int angle_end, int color)
{
	int	x_kreis, y_kreis;
	float winkel;
	#define DEGREE 2*3.14159265/360	
	
	for (winkel = (float)angle_start; winkel <= angle_end; winkel +=1) // Calculate clock hands
	    {
	    x_kreis = (int) (sin (winkel * DEGREE) * radius);
	    y_kreis = (int) (cos (winkel * DEGREE) * radius);
	    LCD.createLine(32,32, x + x_kreis, y - y_kreis, color); //draw clock hands
	    }
}

void clock_main()// full screen clock main
      {
      dayofweek(20,0); // Position x,y
      digital_clock(90,12,0); // Position x,y,TimeZone
      daymonthyear(40, 7);  // Position x,y
      
       if( RTC.get(DS1307_SEC,true) == 00) 
         {
         analog_clock(32,32,18,HR_circle,HR_circle,0 );   //clears Hour clock hands if Second is 0
         analog_clock(32,32,24,MIN_circle,MIN_circle,0 ); //clears Minute clock hands if Second is 0
         }
           analog_clock(32,32,24,SEC_circle,SEC_circle,0 ); //clears Second clock hands every second  
   
   
       HR_circle = RTC.get(DS1307_HR,false); 
    
       if(HR_circle >= 12) HR_circle-=12;
       
       HR_circle = (HR_circle * 30)+(RTC.get(DS1307_MIN,false)/2); // Hour 30 Degrees for next Position and every minute 6 degrees forward
       MIN_circle = RTC.get(DS1307_MIN,false)*6;  // Minute 6 Degrees for next Position
       SEC_circle = RTC.get(DS1307_SEC,false)*6;  // Second 6 Degrees for next Position
       
       // draw clock hands
       analog_clock(32, 32, 24, MIN_circle, MIN_circle, 1); //draw Minute clock hands
       analog_clock(32, 32, 18, HR_circle, HR_circle, 1); //draw Hour clock hands
       analog_clock(32, 32, 24, SEC_circle, SEC_circle, 1); //draw Second clock hands
       
       
       if (state >0) // jump to setclock if state >0
          {
          setclock();
          }    
}



void setup() {
 Serial.begin(9600);
 // Set RTC Instruction
 Serial.println("'s' Set Clock Time and Date"); // so I can keep track of what is loaded
 Serial.println("");
 Serial.println("set the seconds 0-59");
 Serial.println("set the minutes 0-59");
 Serial.println("set the hours 1-23");
 Serial.println("set the day of the week 1-7 Sunday-Saturday");
 Serial.println("set the date 1-28/29/30/31");
 Serial.println("set the month 1-12");
 Serial.println("set the year 0-99");

 
 sensors.begin();
 
  LCD.Initialize();
  LCD.setMode('x','I'); //Mode Set for Reverse Text T6963
  LCD.drawPic( 0, 0, GLCD_Clockbmp ,GLCD_ClockHEIGHT, GLCD_ClockBYTEWIDTH ); // draw Clock Wallpaper
  
}




void loop(){
      // draw Temp line
      sensors.requestTemperatures();
      float tempC = sensors.getTempCByIndex(0);
      dtostrf(tempC,4,2,tVal);    // convert temperature value to xx.xx output format                    
      LCD.TextGoTo(10,7);
      LCD.writeString("Temp:");
      LCD.writeString(tVal);
      LCD.writeString("C ");
 
  
  if (state >0)
     {
      setclock();
     }    
     else if( sec != RTC.get(DS1307_SEC,true))// Draw Clock 
            {
            if (Serial.available() >0)
               {
               char inChar = Serial.read();
               Serial.println(inChar); //
               if (inChar == 's') // s start set clock
                  {
                  Serial.print("Please set the seconds 0-59 : ");
                  state=1;
                  }
              }  
           clock_main();
           }
       
   sec = RTC.get(DS1307_SEC,true); 
   // End draw Clock     
     
  
}
