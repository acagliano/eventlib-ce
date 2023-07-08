
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// EV FLAGS
#define EV_PERSISTENT	0
#define EV_TIMEOUT_IS_INTERVAL	1
struct event {
	uint8_t group_id;
	uint8_t ev_flags;
	uint24_t timeout;
	clock_t ev_pushed;
	uint24_t (*event)(void*, size_t);
	size_t ev_data_len;
	uint8_t ev_data[];
};

typedef enum {
	EV_OK,
	EV_INVALID_ARG,
	EV_ALLOC_THRESHOLD_EXCEEDED,
	EV_ALLOC_FAILURE,
	EV_GROUP0_RESVD,
	EV_DATABUF_OVERFLOW
} ev_status_t;

uint8_t ev_running = 0, ev_write = 0;
void* (*ev_alloc)(size_t) = NULL;
size_t ev_max_alloc = 0;
size_t ev_alloc_current = 0;
uint8_t *ev_ptrs[256];

#define EV_GROUP_ALL	0

ev_status_t ev_start(size_t max_alloc, void* (*alloc)(size_t)){
	if(max_alloc == 0) return EV_INVALID_ARG;
	if(alloc == NULL) return EV_INVALID_ARG;
	ev_max_alloc = max_alloc;
	ev_alloc = alloc;
	return EV_OK;
}

ev_status_t ev_push(uint8_t group_id,
					uint24_t (*event)(void*, size_t),
					void *event_data, size_t event_data_len,
					uint8_t flags, uint24_t timeout_ms){
				  
	uint8_t* ptr;
	
	if(event == NULL) return EV_INVALID_ARG;
	if(group_id == 0) return EV_GROUP0_RESVD;
		
	size_t alloc_this = sizeof(struct event) + event_data_len;
	if((ev_alloc_current + alloc_this) > ev_max_alloc) return EV_ALLOC_THRESHOLD_EXCEEDED;
	if(!(ptr = ev_alloc(alloc_this))) return EV_ALLOC_FAILURE;
	
	ev_alloc_current += alloc_this;
	
	struct event* ev_this = (struct event*)ptr;
	
	ev_this->group_id = group_id;
	ev_this->ev_flags = flags;
	ev_this->timeout = timeout_ms;
	ev_this->event = event;
	ev_this->ev_data_len = event_data_len;
	memcpy(ev_this->ev_data, event_data, event_data_len);
	
	ev_this->ev_pushed = clock();
	
	ev_ptrs[ev_write++] = ptr;
	return EV_OK;
}

ev_status_t ev_pop(uint8_t group_id, uint8_t count){
	uint8_t idx = 0, popped = 0;
	for(; idx != ev_write; idx++){
		if(ev_ptrs[idx]){
			struct event* ev_this = (struct event*)ev_ptrs[idx];
			if((ev_this->group_id == group_id) || (group_id == EV_GROUP_ALL)){
				ev_alloc_current -= (sizeof(struct event) + ev_this->ev_data_len );
				free(ev_ptrs[idx]);
				ev_ptrs[idx] = NULL;
				popped++;
				if(popped == count) break;
			}
		}
	}
	return EV_OK;
}

ev_status_t ev_run(uint8_t count, uint8_t group_id){
	uint8_t idx = 0, processed = 0;
	bool pop_this = false, run_this = true;
	for(; ev_running != ev_write; ev_running++){
		if(ev_ptrs[idx]){
			struct event* ev_this = (struct event*)ev_ptrs[idx];
			if((ev_this->group_id == group_id) || (group_id == EV_GROUP_ALL)){
				
				clock_t ticks_now = clock();
				clock_t ms_elapsed = (ticks_now - ev_this->ev_pushed) * 1000 / CLOCKS_PER_SEC;
				if(ev_this->timeout){
					if(!((ev_this->ev_flags>>EV_TIMEOUT_IS_INTERVAL) & 1)){
						if(ms_elapsed < ev_this->timeout)
							run_this = false;
					}
					else {
						if(ms_elapsed >= ev_this->timeout)
							pop_this = true;
					}
				}
				if(!((ev_this->ev_flags>>EV_PERSISTENT) & 1))
					pop_this = true;
				
				if(run_this)
					ev_this->event(ev_this->ev_data, ev_this->ev_data_len);
			
				if(pop_this){
					ev_alloc_current -= (sizeof(struct event) + ev_this->ev_data_len);
					free(ev_ptrs[idx]);
					ev_ptrs[idx] = NULL;
				}
				
				processed++;
				if(processed == count) break;
			}
		}
	}
	return EV_OK;
}

ev_status_t ev_update(uint8_t group_id, uint8_t count, void* new_data, size_t new_len){
	uint8_t idx = 0, updated = 0;
	for(; idx != ev_write; idx++){
		if(ev_ptrs[idx]){
			struct event* ev_this = (struct event*)ev_ptrs[idx];
			if((ev_this->group_id == group_id) || (group_id == EV_GROUP_ALL)){
				if(new_len > ev_this->ev_data_len) return EV_DATABUF_OVERFLOW;
				ev_this->ev_data_len = new_len;
				memcpy(ev_this->ev_data, new_data, new_len);
				updated++;
				if(updated == count) break;
			}
		}
	}
	return EV_OK;
}


int main(void){
	
}
