
#ifndef BIGBROTHER_H
#define BIGBROTHER_H

enum {
  /* Number of readings per message. If you increase this, you may have to
     increase the message_t size. */
  NREADINGS = 5,

  /* Default sampling period. */
  DEFAULT_INTERVAL = 512,

  AM_BIGBROTHER = 0x94
};

typedef nx_struct bigbrother {
  nx_uint16_t counter; /* Version of the interval. */
  nx_uint16_t interval; /* Samping period. */
  nx_uint16_t id; /* Mote id of sending mote. */
  nx_uint16_t count; /* The readings are samples count * NREADINGS onwards */
  nx_uint16_t readings[NREADINGS];
} bigbrother_t;

#endif
