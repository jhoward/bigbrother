/* Configuration file for the BigBrother application. */

#include "BigBrother.h"
//#include "BigBrotherCmd.h"

configuration BigBrotherAppC { }
implementation
{
  components BigBrotherC, MainC, LedsC;
  components new TimerMilliC(); 
  //components DelugeC;
  
  //
  // Sensor component
  //
  
  components SensorHandlerC;
  
  //
  // Communication components
  //
  
  components CollectionC as Collector, ActiveMessageC,
    new CollectionSenderC(AM_BIGBROTHER),
    SerialActiveMessageC,
    new SerialAMSenderC(AM_BIGBROTHER);
    
  components CC2420CsmaC;

  components new PoolC(message_t, 10) as UARTMessagePoolP,
    new QueueC(message_t*, 10) as UARTQueueP;

  //components TimeSyncAppC;
    

  BigBrotherC.Boot -> MainC;
  BigBrotherC.RadioControl -> ActiveMessageC;
  BigBrotherC.SerialControl -> SerialActiveMessageC;
  BigBrotherC.RoutingControl -> Collector;
  BigBrotherC.Send -> CollectionSenderC;
  BigBrotherC.SerialSend -> SerialAMSenderC.AMSend;
  //BigBrotherC.Snoop -> Collector.Snoop[AM_BIGBROTHERCMD];
  BigBrotherC.Receive -> Collector.Receive[AM_BIGBROTHER];
  BigBrotherC.RootControl -> Collector;
  BigBrotherC.Timer -> TimerMilliC;
  BigBrotherC.SensorHandler -> SensorHandlerC;
  BigBrotherC.Leds -> LedsC;
  BigBrotherC.UARTMessagePool -> UARTMessagePoolP;
  BigBrotherC.UARTQueue -> UARTQueueP;
//	BigBrotherC.DelugeControl -> DelugeC;
  BigBrotherC.SubControl -> CC2420CsmaC;
  //BigBrotherC.GlobalTime -> TimeSyncAppC;
}
