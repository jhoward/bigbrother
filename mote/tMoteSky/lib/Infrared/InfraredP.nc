#include "Msp430Adc12.h"

generic module InfraredP(int adc_id) {
  provides interface DeviceMetadata;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
}
implementation {
  
  msp430adc12_channel_config_t config0 = {
    inch: INPUT_CHANNEL_A0,
    sref: REFERENCE_VREFplus_AVss,
    ref2_5v: REFVOLT_LEVEL_1_5,
    adc12ssel: SHT_SOURCE_ACLK,
    adc12div: SHT_CLOCK_DIV_1,
    sht: SAMPLE_HOLD_4_CYCLES,
    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };
  
  msp430adc12_channel_config_t config1 = {
    inch: INPUT_CHANNEL_A1,
    sref: REFERENCE_VREFplus_AVss,
    ref2_5v: REFVOLT_LEVEL_1_5,
    adc12ssel: SHT_SOURCE_ACLK,
    adc12div: SHT_CLOCK_DIV_1,
    sht: SAMPLE_HOLD_4_CYCLES,
    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  msp430adc12_channel_config_t config2 = {
    inch: INPUT_CHANNEL_A2,
    sref: REFERENCE_VREFplus_AVss,
    ref2_5v: REFVOLT_LEVEL_1_5,
    adc12ssel: SHT_SOURCE_ACLK,
    adc12div: SHT_CLOCK_DIV_1,
    sht: SAMPLE_HOLD_4_CYCLES,
    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  msp430adc12_channel_config_t config3 = {
    inch: INPUT_CHANNEL_A3,
    sref: REFERENCE_VREFplus_AVss,
    ref2_5v: REFVOLT_LEVEL_1_5,
    adc12ssel: SHT_SOURCE_ACLK,
    adc12div: SHT_CLOCK_DIV_1,
    sht: SAMPLE_HOLD_4_CYCLES,
    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  msp430adc12_channel_config_t config6 = {
    inch: INPUT_CHANNEL_A6,
    sref: REFERENCE_VREFplus_AVss,
    ref2_5v: REFVOLT_LEVEL_1_5,
    adc12ssel: SHT_SOURCE_ACLK,
    adc12div: SHT_CLOCK_DIV_1,
    sht: SAMPLE_HOLD_4_CYCLES,
    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  command uint8_t DeviceMetadata.getSignificantBits() { return 12; }
  
  async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration() {
    if(adc_id == 0) {
      return &config0;
    } else if(adc_id == 1) {
			return &config1;
		} else if(adc_id == 2) {
			return &config2;
		} else if(adc_id == 3) {
			return &config3;
		} else {
			return &config6;
    }
  }
}
