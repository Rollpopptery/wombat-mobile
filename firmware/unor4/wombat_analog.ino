/*
Pulse and Sample

wombatpi.net

Modified 14-Apr-2024


Notes:  
The Sample window is sensitive to all digital and analog IO the occurs during,
Thus is enclosed in a no-interrupts block. 
The audio output A0 feeds to high impedance (i.e > 4k) audio amp

*/

#include <Arduino.h>
//#include "pwm.h"
#include "FspTimer.h"
#include "wombat_analog.h"
#include "target_sense.h"


FspTimer pulse_timer;
/*
void setup_adc(void)
{
  // Enable ADC module clock via Module Stop Control Register
  // MSTP register for ADC is typically in MSTPCRD
  #define MSTP_MSTPCRD ((volatile unsigned int *)(0x40047000 + 0x0014))
  #define MSTPD16 16  // ADC140 module stop bit
  
  *MSTP_MSTPCRD &= ~(0x01 << MSTPD16);  // Enable ADC140 module
  delayMicroseconds(10);  // Let it stabilize
  
  // Set up external reference
  *ADC140_ADHVREFCNT = 0x01;  // External AREF (since you're using AR_EXTERNAL)
  
  // Configure sampling time for AN09
  *((volatile unsigned char *)(ADCBASE + 0xC0E9)) = 0x0D;  // ADSSTR09 = 13 clocks
  
  // Configure ADC clock divider
  *ADC140_ADCSR &= ~(0x03 << 8);  // Clear CKS bits
  *ADC140_ADCSR |= (0x00 << 8);   // Set to PCLKD/1 (fastest)

  
  // 14 bit mode, clear ACE bit 5
  *ADC140_ADCER = 0x06;
  
  // Select channel AN09
  *ADC140_ADANSA0 |= (0x01 << 9);
  
  // Enable Group B interrupt if needed
  *ADC140_ADCSR |= (0x01 << 6);
  
  // Trigger first conversion
  *ADC140_ADCSR |= (0x01 << 15);
}
*/
void setupSample() {
  pinMode(D3, OUTPUT);
  pinMode(analogPin, INPUT);  
  analogReference(AR_EXTERNAL);
  analogReadResolution(14);
  uint16_t value = analogRead(analogPin);
  *ADC140_ADCER = 0x06;  // Only this one register change
}
