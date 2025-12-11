/*
 * Optimized ADC140 Setup for Maximum Sample Rate on Arduino UNO R4 Minima
 * Based on RA4M1 Datasheet Analysis
 * 
 * Target: ~1 MHz sample rate in 14-bit mode
 * 
 * Key findings:
 * - 14-bit conversion = tSPL + tSAM
 * - tSAM = 37.5 ADCLK (fixed, high-speed mode)
 * - tSPL = SST × ADCLK + 0.5 ADCLK (minimum SST = 5)
 * - Total minimum = 43 ADCLK cycles
 * - At 48MHz ADCLK: 0.90 µs = 1.11 MHz max
 */

#include "Arduino.h"

// ADC Base Address
#define ADCBASE 0x40050000

// ADC Registers
#define ADC140_ADCSR   ((volatile unsigned short *)(ADCBASE + 0xC000))
#define ADC140_ADANSA0 ((volatile unsigned short *)(ADCBASE + 0xC004))
#define ADC140_ADCER   ((volatile unsigned short *)(ADCBASE + 0xC00E))
#define ADC140_ADDR01  ((volatile unsigned short *)(ADCBASE + 0xC022))

// ADC Sampling State Registers (one per channel)
#define ADC140_ADSSTR01 ((volatile unsigned char *)(ADCBASE + 0xC0E1))

// ADC High/Low Voltage Reference Control
#define ADC140_ADHVREFCNT ((volatile unsigned char *)(ADCBASE + 0xC08A))

// Module Stop Control for ADC
#define MSTP_MSTPCRD ((volatile unsigned int *)(0x40047014))
#define MSTPD16 16

// Port Function Select
#define PORTBASE 0x40040000
#define PFS_P103PFS_BY ((volatile unsigned char  *)(PORTBASE + 0x0843 + (3 * 4)))




void setup_adc_maximum_speed(void) {
  // CRITICAL: We need to initialize EVERYTHING ourselves for maximum control
  // This approach tries to minimize what we change after analogRead() init
  
  // Step 1: Use Arduino's analogRead to do basic initialization
  pinMode(analogPin, INPUT);
  analogReference(AR_EXTERNAL);
  analogReadResolution(14);
  uint16_t dummy = analogRead(analogPin);  // Initialize everything
  
  // Step 2: Now optimize only the sampling time register
  // Set ADSSTR01 to minimum value = 5 states
  // This gives: tSPL = 5 × ADCLK + 0.5 ADCLK = 5.5 ADCLK
  // Total conversion = 5.5 + 37.5 = 43 ADCLK cycles
  *ADC140_ADSSTR01 = 0x05;  // Minimum sampling time for AN001
  
  Serial.println("ADC optimized:");
  Serial.print("  ADSSTR01 = 0x");
  Serial.println(*ADC140_ADSSTR01, HEX);
  Serial.print("  ADCSR = 0x");
  Serial.println(*ADC140_ADCSR, HEX);
  Serial.print("  ADCER = 0x");
  Serial.println(*ADC140_ADCER, HEX);
}

/* ALTERNATIVE APPROACH - Full manual initialization (RISKY!)
 * 
 * This would bypass analogRead() entirely but requires careful setup
 * of all registers. Only try this if the above doesn't achieve 1 MHz.
 */

void setup_adc_full_manual(void) {
  // Enable ADC module clock
  *MSTP_MSTPCRD &= ~(0x01 << MSTPD16);
  delayMicroseconds(10);
  
  // External AREF
  *ADC140_ADHVREFCNT = 0x01;
  
  // Select 14-bit mode, high-speed mode
  // ADPRC[1:0] = 10b (14-bit), ACE = 0
  *ADC140_ADCER = 0x06;
  
  // Set minimum sampling time (5 ADCLK)
  *ADC140_ADSSTR01 = 0x05;
  
  // Select channel AN001
  *ADC140_ADANSA0 = (0x01 << 1);
  
  // Configure ADCSR
  // CKS[1:0] bits 8-9 = 00b for PCLKB/1 (try different values if needed)
  // ADST bit 15 will be set when starting conversion
  *ADC140_ADCSR = 0x0000;
  *ADC140_ADCSR |= (0x00 << 8);  // Clock divider = /1
  
  // Trigger first conversion
  *ADC140_ADCSR |= (0x01 << 15);
}
