
// Disable this entire file (not using this coil)
//
#if 0  



/*
---------------------------------------------------------------------
428 uH coil

Diameter:   20cm
Inductance: 428
Turns:      
Wire:       0.5mm copper


Damping resistor ~ 

---------------------------------------------------------------------
*/

#include "coil_20_428.h"

#include "voice.h"

// target sense calculation happens if above this threshold
//
#define THRESHOLD (20)



// called repeatedly every sample, i.e at up to 500Hz,
// must be efficient
//
/*
void COIL_20_1364::doSampleAveraging()
{
  static int averageCount = 0;  

  double tempF;
  int index;
  double oldSample;

  // reference sample
  //
  uint16_t lastSample = sampleArray[SAMPLE_COUNT_MAX-1]; 

  for(index = 0 ; index < TIME_POINTS; index++)
    {
      
      oldSample = samples[index][averageCount];      

      samples[index][averageCount] = sampleArray[( INDEX_30uSEC + index )];   // new raw sample from the set of samples
      //samples[index][averageCount] -= lastSample;

      sums[index] -= oldSample;    // subtract old value from the sum
      sums[index] += samples[index][averageCount];  // add the new value to the sum      
    }

    // recalculate the running averages
    //    
    for(index = 0; index < TIME_POINTS; index++)
    {
      averages[index] = (sums[index] / SAMPLE_BUFFER_LENGTH);    
    }
    
    averageCount++;   

    if(averageCount >= SAMPLE_BUFFER_LENGTH)
    {     
      // full set of samples complete
      //
      averageCount = 0;

      for(index = 0 ; index < TIME_POINTS; index++)
      {
        // re-calculate long averages
        //          
        tempF = (averages[index] -  longAverages[index]);
        tempF /= LONG_AVERAGE_FACTOR;          
        longAverages[index] += tempF;     

        // fast recovery, after the average has 'wound-up' due to being held on a target.
        // i.e The average follows the signal down quicker than it follows the signal up.
        //
        if(tempF < 0)
        { 
           // add it again
           //
           longAverages[index] += tempF;    
        }
      }     
    }
}
*/

// called repeatedly every sample, i.e at up to 500Hz,
// must be efficient
//
void COIL_20_428::doSampleAveragingMobile()
{
  static int averageCount = 0;  

  double tempF;
  int index;
  double oldSample;

  // reference sample
  //
  uint16_t lastSample = sampleArray[SAMPLE_COUNT_MAX-1]; 

  for(index = 0 ; index < TIME_POINTS; index++)
    {
      
      oldSample = samples[index][averageCount];      

      samples[index][averageCount] = sampleArray[(index)];   // new raw sample from the set of samples
      //samples[index][averageCount] -= lastSample;

      sums[index] -= oldSample;    // subtract old value from the sum
      sums[index] += samples[index][averageCount];  // add the new value to the sum      
    }

    // recalculate the running averages
    //    
    for(index = 0; index < TIME_POINTS; index++)
    {
      averages[index] = (sums[index] / SAMPLE_BUFFER_LENGTH);    
    }
    
    averageCount++;   

    if(averageCount >= SAMPLE_BUFFER_LENGTH)
    {     
      // full set of samples complete
      //
      averageCount = 0;
      
    }
}



//
// Send the discharge curve (averaged)
//
void COIL_20_428::send()
{
  int sendSampleCount = 0;
  

  for(sendSampleCount = 0 ; sendSampleCount < TIME_POINTS; sendSampleCount++)
  {
   
    Serial.print(averages[sendSampleCount]);
    Serial.print(",");   
  }
     
  
  // send sampleblock 'end' 
  //
  Serial.println("");
  Serial.flush();
  
 

}




#endif
