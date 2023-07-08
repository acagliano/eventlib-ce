
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <time.h>

// EV FLAGS
#define EV_PERSISTENT	0
#define EV_TIMEOUT_IS_INTERVAL	1
struct ev {
	uint24_t event_id;
	bool enabled, triggered;
	uint24_t (*callback)(void*, size_t);
	size_t callback_data_len;
	uint8_t callback_data[];
};



typedef enum {
	EV_OK,
	EV_INVALID_ARG,
	EV_ALLOC_THRESHOLD_EXCEEDED,
	EV_ALLOC_FAILURE,
	EV_DATABUF_OVERFLOW
} ev_status_t;

uint8_t ev_running = 0, ev_write = 0;
void* (*ev_realloc)(void*, size_t) = NULL;
size_t ev_max_alloc = 0;
size_t ev_alloc_current = 0;
uint8_t *ev_queue;


ev_status_t ev_setup(size_t max_alloc, void* (*realloc)(void*, size_t)){
	if(max_alloc == 0) return EV_INVALID_ARG;
	if(realloc == NULL) return EV_INVALID_ARG;
	ev_max_alloc = max_alloc;
	ev_realloc = realloc;
	return EV_OK;
}

ev_status_t ev_register(uint24_t event_id,
						uint24_t (*callback)(void*, size_t),
						void *callback_data, size_t callback_data_len){
	
	if(callback == NULL) return EV_INVALID_ARG;
	
	uint8_t *ptr_start = ev_queue;
	uint8_t *ptr_end = ev_queue + ev_alloc_current;
	struct ev* ev_this = NULL;
	
	for(uint8_t* curr = ptr_start; curr < ptr_end;){
		struct ev *ev_tmp = (struct ev*)curr;
		
		if(ev_tmp->event_id == event_id){
			if(ev_tmp->callback_data_len < callback_data_len)
				return EV_DATABUF_OVERFLOW;
			ev_this = ev_tmp;
			break;
		}
		curr += (sizeof(struct ev) + ev_tmp->callback_data_len);
	}
	
	if(ev_this == NULL){
		size_t alloc_this = sizeof(struct ev) + callback_data_len;
		if((ev_alloc_current + alloc_this) > ev_max_alloc) return EV_ALLOC_THRESHOLD_EXCEEDED;
		
		uint8_t *ptr = ev_realloc(ev_queue, ev_alloc_current + alloc_this);
		if(ptr == NULL) return EV_ALLOC_FAILURE;
		
		ev_queue = ptr;
		
		ev_this = (struct ev*)ev_queue + ev_alloc_current;
		ev_alloc_current += alloc_this;
		memset(ev_this, 0, sizeof(struct ev) + callback_data_len);
	}
	
	ev_this->event_id = event_id;
	ev_this->callback = callback;
	ev_this->callback_data_len = callback_data_len;
	memcpy(ev_this->callback_data, callback_data, callback_data_len);

	return EV_OK;
}

ev_status_t ev_enable(uint8_t event_id){
	
	uint8_t *ptr_start = ev_queue;
	uint8_t *ptr_end = ev_queue + ev_alloc_current;
	
	for(uint8_t* curr = ptr_start; curr < ptr_end;){
		struct ev *ev_this = (struct ev*)curr;
		
		if(ev_this->event_id == event_id)
		   ev_this->enabled = true;
		
		curr += (sizeof(struct ev) + ev_this->callback_data_len);
	}
	return EV_OK;
}

ev_status_t ev_disable(uint8_t event_id){
	
	uint8_t *ptr_start = ev_queue;
	uint8_t *ptr_end = ev_queue + ev_alloc_current;
	
	for(uint8_t* curr = ptr_start; curr < ptr_end;){
		struct ev *ev_this = (struct ev*)curr;
		
		if(ev_this->event_id == event_id)
		   ev_this->enabled = false;
		
		curr += (sizeof(struct ev) + ev_this->callback_data_len);
	}
	return EV_OK;
}
		   
ev_status_t ev_trigger(uint8_t event_id){
	uint8_t *ptr_start = ev_queue;
	uint8_t *ptr_end = ev_queue + ev_alloc_current;
	
	for(uint8_t* curr = ptr_start; curr < ptr_end;){
		struct ev *ev_this = (struct ev*)curr;
		
		if(ev_this->event_id == event_id)
			ev_this->triggered = true;
		
		curr += (sizeof(struct ev) + ev_this->callback_data_len);
	}
	return EV_OK;
}

ev_status_t ev_check(){
	
	uint8_t *ptr_start = ev_queue;
	uint8_t *ptr_end = ev_queue + ev_alloc_current;
	
	for(uint8_t* curr = ptr_start; curr < ptr_end;){
		struct ev *ev_this = (struct ev*)curr;
		
		if(ev_this->enabled && ev_this->triggered)
			ev_this->callback(ev_this->callback_data, ev_this->callback_data_len);
		
		curr += (sizeof(struct ev) + ev_this->callback_data_len);
	}
	return EV_OK;
}


int main(void){
	
}
