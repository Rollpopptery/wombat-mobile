/*
---------------------------------------------------------------------
1364 uH coil

Diameter:   20cm
Inductance: 1364
Turns:      53  
Wire:       0.5mm copper


Damping resistor ~ 470 ohms

---------------------------------------------------------------------
*/

#include "coil_20_1364.h"

#include "voice.h"





// called repeatedly every sample, i.e at up to 500Hz,
// must be efficient
//
void COIL_20_1364::doSampleAveragingMobile()
{
  static int averageCount = 0;  

  double tempF;
  int index;
  double oldSample;

 

  for(index = 0 ; index < FIRST_BLOCK; index++)
    {
      
      oldSample = samples[index][averageCount];      

      samples[index][averageCount] = sampleArray[(index)];   // new raw sample from the set of samples
      

      sums[index] -= oldSample;    // subtract old value from the sum
      sums[index] += samples[index][averageCount];  // add the new value to the sum      
    }

  // second sample block, on late part of the curve
  //
  for(index = FIRST_BLOCK ; index < TIME_POINTS; index++)
    {
      
      oldSample = samples[index][averageCount];      

      samples[index][averageCount] = sampleArray[(index + SECOND_BLOCK_OFFSET)];   // new raw sample from the set of samples
      

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


// Copy to temporary send buffer at set flag
//
void COIL_20_1364::dataBlockSend()
  {
    for(int i = 0 ; i < TIME_POINTS; i++)
    {
      // locked in time, so data in a single curve is all in sync
      //
      sendBuffer[i] = averages[i];
    }
    dataSendFlag = true;    
  }







//
// Send the discharge curve (averaged)
//
void COIL_20_1364::send()
{
  static int countSamples = 0;
  
  if(! dataSendFlag)
  {
    return;
  }  
  

  Serial.print(sendBuffer[countSamples]);
  Serial.print(",");   
  Serial.flush();
  
     
  countSamples++;
  if(countSamples >= TIME_POINTS)
  {
    countSamples = 0;
    // send sampleblock 'end' 
    //
    Serial.println("");
    Serial.flush();
    dataSendFlag = false;
  }
  
 

}
