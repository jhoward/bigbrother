/* Configuration file for the SensorHandler component. */

configuration SensorHandlerC {
  provides interface SensorHandler;
}

implementation {
  
  components SensorHandlerP as App;
  components new InfraredC(0) as Sensor0;
  components new InfraredC(1) as Sensor1;
  components new InfraredC(2) as Sensor2;
  components new InfraredC(3) as Sensor3;
  components new InfraredC(6) as Sensor6;
  components LedsC;

  SensorHandler = App;
  App.ReadSensor0 -> Sensor0;
  App.ReadSensor1 -> Sensor1;
  App.ReadSensor2 -> Sensor2;
  App.ReadSensor3 -> Sensor3;
  App.ReadSensor6 -> Sensor6;
  App.Leds -> LedsC;

}


