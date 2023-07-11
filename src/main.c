
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <time.h>

#include <ti/getkey.h>
#include <stdio.h>



struct ev {
	bool slot_used;
	uint24_t event_id;
	bool enabled, triggered;
	void (*callback)(void*, size_t);
	size_t callback_data_len;
	void* callback_data;
	uint8_t ev_flags;
};

#define CEMU_CONSOLE ((char*)0xFB0000)

typedef enum {
	EV_INVALID_ARG,
	EV_THRESHOLD_EXCEEDED,
	EV_ALLOC_FAILURE,
	EV_DATABUF_OVERFLOW
} ev_status_t;

void* (*ev_malloc)(size_t) = NULL;
void (*ev_free)(void*) = NULL;

#define EV_SLOTS_MAX 256
struct ev ev_queue[EV_SLOTS_MAX];


bool ev_Setup(void* (*malloc)(size_t), void (*free)(void*)){
	if(malloc == NULL || free==NULL) return false;
	ev_malloc = malloc;
	ev_free = free;
	return true;
}

enum _ev_flags {
	EV_AUTOENABLE_WATCHER	= 0,
	EV_DISABLE_AFTER_RUN	= 1,
};

int ev_RegisterEvent(uint8_t event_id,
						uint8_t ev_flags,
						void (*callback)(void*, size_t),
						void *callback_data, size_t callback_data_len){
	
	if(callback == NULL) return -1;
	
	int i = 0;
	
	void* data = ev_malloc(callback_data_len);
	if(data==NULL) return -1;
	memcpy(data, callback_data, callback_data_len);
	
	for(; i < EV_SLOTS_MAX; i++)
		if(!ev_queue[i].slot_used) break;
	
	if(i == EV_SLOTS_MAX) return -1;
		
	struct ev *this = &ev_queue[i];
	
	this->event_id = event_id;
	this->callback = callback;
	this->callback_data_len = callback_data_len;
	this->callback_data = data;
	this->ev_flags = ev_flags;
	this->slot_used = true;
	
	if(ev_flags & (1 << EV_AUTOENABLE_WATCHER)) this->enabled = true;

	return i;
}

bool ev_UnregisterEvent(int slot){
	
	if(slot >= EV_SLOTS_MAX) return false;
	struct ev *this = &ev_queue[slot];
	
	ev_free(this->callback_data);
	memset(this, 0, sizeof(struct ev));
	return true;
}

bool ev_UpdateCallbacks(int slot, void (*callback)(void*, size_t), void* callback_data, size_t callback_data_len, void* (*realloc)(void*, size_t)){
	
	if(slot >= EV_SLOTS_MAX) return false;
	
	struct ev *this = &ev_queue[slot];
	if(!this->slot_used) return false;
	
	if(callback) this->callback = callback;
	if(callback_data && callback_data_len){
		if(this->callback_data_len != callback_data_len){
			uint8_t *ptr = realloc(this->callback_data, callback_data_len);
			if(!ptr) return false;
			this->callback_data = ptr;
			this->callback_data_len = callback_data_len;
		}
		memcpy(this->callback_data, callback_data, callback_data_len);
	}
	
	return true;
}

void ev_PurgeEvent(uint8_t event_id, uint8_t num){
	size_t ct = 0;
	
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		if(this->event_id == event_id){
			ev_free(this->callback_data);
			memset(this, 0, sizeof(struct ev));
			if(ct++ == num) break;
		}
	}
}

void ev_Watch(uint8_t event_id){
	
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		if(this->event_id == event_id)
			this->enabled = true;
	}
}

void ev_Unwatch(uint8_t event_id){
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		if(this->event_id == event_id)
			this->enabled = true;
	}
}
		   
void ev_Trigger(uint8_t event_id){
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		if((this->event_id == event_id) && this->enabled)
			this->triggered = true;
	}
}

void ev_HandleEvents(void){
	
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		if(this->enabled && this->triggered){
			this->callback(this->callback_data, this->callback_data_len);
			if(this->ev_flags & (1 << EV_DISABLE_AFTER_RUN)) this->enabled = false;
		}
	}
}

void ev_Cleanup(void){
	for(int i = 0; i < EV_SLOTS_MAX; i++){
		if(!ev_queue[i].slot_used) continue;
		struct ev *this = &ev_queue[i];
		
		ev_free(this->callback_data);
	}
}

#define EV0 0
#define EV1 1
int main(void){
}
