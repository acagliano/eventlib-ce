
#ifndef eventlib_h
#define eventlib_h

#include <stdint.h>

typedef enum {
	EV_OK,
	EV_INVALID_ARG,
	EV_THRESHOLD_EXCEEDED,
	EV_ALLOC_FAILURE,
	EV_DATABUF_OVERFLOW
} ev_status_t;

ev_status_t ev_setup(size_t max_events, void* (*malloc)(size_t));

ev_status_t ev_register(uint24_t event_id,
						void (*callback)(void*, size_t),
						void *callback_data, size_t callback_data_len);

ev_status_t ev_watch(uint24_t event_id);

ev_status_t ev_unwatch(uint24_t event_id);

ev_status_t ev_trigger(uint24_t event_id);

ev_status_t ev_handle(void);

void ev_cleanup(void (*free)(void*));

#endif
