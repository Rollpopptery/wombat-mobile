/*
----------------------------------------------------------------------------

WOMBAT PI-MOBILE Metal detector
Arduino UNO R4 Minima Version

wombatpi.net

Last Modified:  07 Dec 2025


----------------------------------------------------------------------------
*/

#define VERSION "21DEC2025"

#include "wombat.h"
#include "wombat_analog.h"
#include "target_sense.h"

#define BAUD_RATE (1000000)

void setup() 
{  

  Serial.begin(BAUD_RATE); 
  delay(200) ;  // charge the capacitor
  setupSample();

 
  setup_soundWave();    // Audio and pulsing    

  // Not used
  //
  if(WIFI_SERIAL_ENABLED)
  {
    Serial1.begin(BAUD_RATE);
  }
}


void loop() 
{  
  static int soundUpdateCount = -4000; // this counts up, and provides an initial delay before outputting sound
  
  static double sum = 0.0;
  static int serialCheckCount = 0;   // check the serial port periodically
  static int printOutCount = 0;
  static int newAverageCounter;
  static double maxF;
  static int medianCounter = 0;
  static int loopCounter = 0;   

  int oldSample; 
  int index = 0;  
  double tempF ; 
  double signal;    
  
  if(sampleReady)
  {
    sampleReady = false;      
     
    theCoil.doSampleAveragingMobile(); 

    

    // Do our Discrimination and Target ID here if it's time
    //    
    // i.e If 450 Hz pulse rate, with 25-sample buffer, we will do this 600/50 = 12 times per second) 
    //
    if (printOutCount++  > SAMPLE_BUFFER_LENGTH)
    {  
      printOutCount = 0; 
      
      theCoil.send();
  
    } 

   
  }
} 
