
// include needed headers here


module SensorHandlerP {
  uses {
    interface Read<uint16_t> as ReadSensor0;
    interface Read<uint16_t> as ReadSensor1;
    interface Read<uint16_t> as ReadSensor2;
    interface Read<uint16_t> as ReadSensor3;
    interface Read<uint16_t> as ReadSensor6;
		interface Leds;
  }
  provides {
    interface SensorHandler;
  }
}
implementation {

  #define HIGH_LOWER_BOUND 4090
  #define HIGH_UPPER_BOUND 5000
  #define LOW_LOWER_BOUND 35
  #define LOW_UPPER_BOUND 55
  
  error_t testData(uint16_t* data, uint16_t reading) {

#ifndef RAW_DUMP			
    if((reading > HIGH_LOWER_BOUND) & (reading < HIGH_UPPER_BOUND)) {
      *data = 0;
      return SUCCESS;
    } else if((reading < LOW_UPPER_BOUND) & (reading > LOW_LOWER_BOUND)) {
      *data = 1;
      return SUCCESS;
		} else {
			return FAIL;
    }
#else	
		*data = reading;
		return SUCCESS; 
#endif
  } 

  bool locked;
  
  uint16_t readings[5];

  command error_t SensorHandler.start() {
		locked = FALSE;
		return SUCCESS;
	}
    
  command error_t SensorHandler.readSensors() {
	call Leds.led1Toggle();
    if(!locked) {
      unsigned int i;
      locked = TRUE;
			for(i = 0; i < 5; ++i) {
        readings[i] = 0;
			}
      call ReadSensor0.read();
      return SUCCESS;
		} else {
			return FAIL;
		}
  }

  event void ReadSensor0.readDone(error_t result, uint16_t data) {
	  if(result != SUCCESS) {
			call ReadSensor0.read();
		} else {
		  if(testData(&readings[0], data) == SUCCESS) {	
			  call ReadSensor1.read();
			} else {
				call ReadSensor0.read();
			}
		}
  }
  
  event void ReadSensor1.readDone(error_t result, uint16_t data) {
	  if(result != SUCCESS) {
			call ReadSensor1.read();
		} else {
		  if(testData(&readings[1], data) == SUCCESS) {	
			  call ReadSensor2.read();
			} else {
				call ReadSensor1.read();
			}
		}
  }
  
  event void ReadSensor2.readDone(error_t result, uint16_t data) {
	  if(result != SUCCESS) {
			call ReadSensor2.read();
		} else {
		  if(testData(&readings[2], data) == SUCCESS) {	
			  call ReadSensor3.read();
			} else {
				call ReadSensor2.read();
			}
		}
  }
  
  event void ReadSensor3.readDone(error_t result, uint16_t data) {
	  if(result != SUCCESS) {
			call ReadSensor3.read();
		} else {
		  if(testData(&readings[3], data) == SUCCESS) {	
			  call ReadSensor6.read();
			} else {
				call ReadSensor3.read();
			}
		}
  }
  
  event void ReadSensor6.readDone(error_t result, uint16_t data) {
	  if(result != SUCCESS) {
			call ReadSensor6.read();
		} else {
		  if(testData(&readings[4], data) == SUCCESS) {	
			  signal SensorHandler.readingDone(readings);
				locked = FALSE;
			} else {
				call ReadSensor6.read();
			}
		}
  }

}

