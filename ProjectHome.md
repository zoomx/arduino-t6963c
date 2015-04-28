
```
Graphic LCD with Toshiba T6963 controller
Copyright (c) Rados?aw Kwiecie?, 2007r
http://en.radzio.dxp.pl/t6963/
Compiler : avr-gcc

Modified By -rbrsidedn1- to work on Arduino easily : http://domoduino.tumblr.com/


Features added by big-maec : Text Attribute, Image View with bmp2c, Play Anim with bmp2c,
filled Box, String with Font use GLCD_Env_1.3, Demo Sketch 240x64 (30K Memory needed), ARDUINO MEGA SUPPORT.

Tested with Arduino 0022
```


> http://arduino-t6963c.googlecode.com/hg/P/T6963c_lib.JPG



```


Arduino Clock Sketch for T6963c librarie

09.02.2011 Sketch T6963c_Font_Clock online. 
Shows a Analog Clock, Digital Clock, Dayweek and Temp. Set RTC DS1307 use Arduino IDE buildin Serial Monitor. 
RTC uses the i2c bus, pins 4 (sda) and 5 (scl) (labeled on the board) on the Duemilanove, and 20 and 21 on the Mega. 
DS18B20 wired at Pin11.

```
> ![http://arduino-t6963c.googlecode.com/hg/P/T6963_Font_Clock_1.jpg](http://arduino-t6963c.googlecode.com/hg/P/T6963_Font_Clock_1.jpg)