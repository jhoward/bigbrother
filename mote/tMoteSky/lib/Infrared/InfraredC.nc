/**
 * InfraredC is a driver for a total solar radiation sensor
 * available on the telosb platform.
 *
 * @author Gilman Tolle <gtolle@archrock.com>
 * @version $Revision: 1.5 $ $Date: 2007/04/13 21:46:18 $
 */

generic configuration InfraredC(int adc_id) {
  provides interface DeviceMetadata;
  provides interface Read<uint16_t>;
  provides interface ReadStream<uint16_t>;
}
implementation {
  components new AdcReadClientC();
  Read = AdcReadClientC;

  components new AdcReadStreamClientC();
  ReadStream = AdcReadStreamClientC;

  components new InfraredP(adc_id);
  DeviceMetadata = InfraredP;
  AdcReadClientC.AdcConfigure -> InfraredP;
  AdcReadStreamClientC.AdcConfigure -> InfraredP;
}
