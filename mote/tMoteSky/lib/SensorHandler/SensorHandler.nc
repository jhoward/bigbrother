/* Interface for the SensorHandler component. */

interface SensorHandler {
  command error_t readSensors();
	command error_t start();
  event error_t readingDone(uint16_t* readings); 
}
