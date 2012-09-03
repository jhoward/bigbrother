/* Module for the BigBrother application. */

#include "Timer.h"
#include "BigBrother.h"

module BigBrotherC {
  uses {
    // Interfaces for initialization:
    interface Boot;
    interface SplitControl as RadioControl;
    interface SplitControl as SerialControl;
	interface SplitControl as SubControl;
    interface StdControl as RoutingControl;
	//interface StdControl as DelugeControl;
    
    // Interfaces for communication, multihop and serial:
    interface Send;
    //interface Receive as Snoop;
    interface Receive;
    interface AMSend as SerialSend;
    interface CollectionPacket;
    interface RootControl;

    interface Queue<message_t *> as UARTQueue;
    interface Pool<message_t> as UARTMessagePool;

    // Miscalleny:
    interface Timer<TMilli>;
    interface Leds;
    
    interface SensorHandler;
    //interface GlobalTime;
  }
}

implementation {
  task void uartSendTask();
  static void startTimer();
  static void fatal_problem();
  static void report_problem();
  static void report_sent();
  static void report_received();

  uint8_t uartlen;
  message_t sendbuf;
  message_t uartbuf;
  bool sendbusy=FALSE, uartbusy=FALSE;
  /* Deluge and sensors can't run at the same time. Use this as a lock. */
  bool running_lock;

  /* Current local state - interval, version and accumulated readings */
  bigbrother_t local;

  uint8_t reading; /* 0 to NREADINGS */

  uint16_t counter;

  bool suppress_count_change;

  // 
  // On bootup, initialize radio and serial communications, and our
  // own state variables.
  //
  event void Boot.booted() {
    local.interval = DEFAULT_INTERVAL;
    local.id = TOS_NODE_ID;
    local.counter = 0;
	
	counter = 0;	

    // Beginning our initialization phases:
    if (call RadioControl.start() != SUCCESS)
      fatal_problem();

    if (call RoutingControl.start() != SUCCESS)
      fatal_problem();
    
    if ( call SensorHandler.start() != SUCCESS)
      fatal_problem();
}

  event void RadioControl.startDone(error_t error) {
    if (error != SUCCESS)
      fatal_problem();

    if (sizeof(local) > call Send.maxPayloadLength())
      fatal_problem();

    if (call SerialControl.start() != SUCCESS)
      fatal_problem();
}

  event void SerialControl.startDone(error_t error) {
    if (error != SUCCESS)
      fatal_problem();

    // This is how to set yourself as a root to the collection layer:
    if (local.id == 0) {
      call RootControl.setRoot();
		} else {
   		startTimer();
		}
}

  static void startTimer() {
    if (call Timer.isRunning()) call Timer.stop();
    call Timer.startPeriodic(local.interval);
    reading = 0;
}

  event void RadioControl.stopDone(error_t error) { }
  event void SerialControl.stopDone(error_t error) { }

  //
  // Only the root will receive messages from this interface; its job
  // is to forward them to the serial uart for processing on the pc
  // connected to the sensor network.
  //
  event message_t*
  Receive.receive(message_t* msg, void *payload, uint8_t len) {
    bigbrother_t* in = (bigbrother_t*)payload;
    bigbrother_t* out;
    if (uartbusy == FALSE) {
      out = (bigbrother_t*)call SerialSend.getPayload(&uartbuf, sizeof(bigbrother_t));
      if (len != sizeof(bigbrother_t)) {
	    return msg;
      }
      else {
	    memcpy(out, in, sizeof(bigbrother_t));
      }
      uartlen = sizeof(bigbrother_t);
      post uartSendTask();
    } else {
      // The UART is busy; queue up messages and service them when the
      // UART becomes free.
      message_t *newmsg = call UARTMessagePool.get();
      if (newmsg == NULL) {
        // drop the message on the floor if we run out of queue space.
        report_problem();
        return msg;
      }

      //Prepare message to be sent over the uart
      out = (bigbrother_t*)call SerialSend.getPayload(newmsg, sizeof(bigbrother_t));
      memcpy(out, in, sizeof(bigbrother_t));

      if (call UARTQueue.enqueue(newmsg) != SUCCESS) {
        // drop the message on the floor and hang if we run out of
        // queue space without running out of queue space first (this
        // should not occur).
        call UARTMessagePool.put(newmsg);
        fatal_problem();
        return msg;
      }
    }

    return msg;
  }

  task void uartSendTask() {
    if (call SerialSend.send(0xffff, &uartbuf, uartlen) != SUCCESS) {
      report_problem();
    } else {
      uartbusy = TRUE;
    }
  }

  event void SerialSend.sendDone(message_t *msg, error_t error) {
    uartbusy = FALSE;
    if (call UARTQueue.empty() == FALSE) {
      // We just finished a UART send, and the uart queue is
      // non-empty.  Let's start a new one.
      message_t *queuemsg = call UARTQueue.dequeue();
      if (queuemsg == NULL) {
        fatal_problem();
        return;
      }
      memcpy(&uartbuf, queuemsg, sizeof(message_t));
      if (call UARTMessagePool.put(queuemsg) != SUCCESS) {
        fatal_problem();
        return;
      }
      post uartSendTask();
    }
  }

  //
  // Overhearing other traffic in the network.
  //
 // event message_t* 
 // Snoop.receive(message_t* msg, void* payload, uint8_t len) {
    //bigbrothercmd_t *cmdmsg = payload;

    //report_received();
		/*
		if(cmdmsg->dest_id == TOS_LOCAL_ADDR || cmdmsg->dest_id == 0xffff) {
			if(cmdmsg->command_type == STOP_DELUGE) {

			} else if(cmdmsg->command_type == START_DELUGE) {

			} else if(cmdmsg->command_type == STOP_SENSORS) {

			} else if(cmdmsg->command_type == START_SENSORS) {

			}

		}

    // If we receive a newer version, update our interval. 
    if (bbmsg->version > local.version) {
      local.version = bbmsg->version;
      local.interval = bbmsg->interval;
      startTimer();
    }
		*/

  //  return msg;
 //}

  /* At each sample period:
     - call SensorHandler.readSensors(), which will read from the five infrared 		sensors 
  */
  event void Timer.fired() {
	//call Leds.led1Toggle();
    if (call SensorHandler.readSensors() != SUCCESS)
      report_problem();
	}

  /* Event triggered when reading is completed. If a nonzero is contained in the 		 readings, send packet.
  */
  event error_t SensorHandler.readingDone(uint16_t* readings) {
    unsigned int i;
    bool b;
    b = FALSE;

    // Check readings for nonzero. Set b to true if nonzero, false otherwise.
    for(i = 0; i < 5; ++i) {
      local.readings[reading++] = readings[i];
      b |= local.readings[i];
    }

    // Used to identify packets and filter out duplicates at the base. 
	 local.counter = counter++%256;

#ifndef RAW_DUMP
    if (b) {
      if (!sendbusy) {
				bigbrother_t *o = (bigbrother_t *)call Send.getPayload(&sendbuf, sizeof(bigbrother_t));
				memcpy(o, &local, sizeof(local));
				if (call Send.send(&sendbuf, sizeof(local)) == SUCCESS) {
	  			  sendbusy = TRUE;
				}	else {
  				  report_problem();
				}
		}
      
      reading = 0;
      /* Part 2 of cheap "time sync": increment our count if we didn't
         jump ahead. */
      if (!suppress_count_change)
        local.count++;
      suppress_count_change = FALSE;
		} else {
			reading = 0;
		}
// If RAW_DUMP flag is set, always send data
#else
      if (!sendbusy) {
				bigbrother_t *o = (bigbrother_t *)call Send.getPayload(&sendbuf);
				memcpy(o, &local, sizeof(local));
				if (call Send.send(&sendbuf, sizeof(local)) == SUCCESS) {
	  			sendbusy = TRUE;
				}	else {
  				report_problem();
				}
			}
      
      reading = 0;
      /* Part 2 of cheap "time sync": increment our count if we didn't
         jump ahead. */
      if (!suppress_count_change)
        local.count++;
      suppress_count_change = FALSE;
#endif
    return SUCCESS;
  }

  event void Send.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      report_sent();
    else
      report_problem();

    sendbusy = FALSE;
  }

	/* SubControl events. */

	event void SubControl.startDone(error_t error) {


	}

	event void SubControl.stopDone(error_t error) {



	}


  /* Time Syncronization Events. */
  /*
  event void GlobalTime.synced(){ 
  }
  */

  /***************** Tasks ****************/
  task void stopRadio() {
    error_t error = call SubControl.stop();
    if(error != SUCCESS) {
      // Already stopped?
      //finishSplitControlRequests();
      //call OnTimer.startOneShot(sleepInterval);
    }
  }

  task void startRadio() {
    if(call SubControl.start() != SUCCESS) {
      post startRadio();
    }
  }
  
  // Use LEDs to report various status issues.
  static void fatal_problem() { 
    call Timer.stop();
    call Leds.led0On(); 
    call Leds.led1On();
    call Leds.led2On();
}

  static void report_problem() { /*call Leds.led0Toggle();*/ }
  static void report_sent() { call Leds.led1Toggle(); }
  static void report_received() { call Leds.led2Toggle(); }
}
