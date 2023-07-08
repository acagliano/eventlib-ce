/*
 *--------------------------------------
 * Program Name:
 * Author:
 * License:
 * Description:
 *--------------------------------------
*/

#include <tice.h>
#include <ti/getkey.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <eventlib.h>

#define EVENT_0		0

void event0_do(void* data, size_t len){
	size_t *v = (size_t*)data;
	printf("value: %u", *v);
}

void some_function(void){
	ev_trigger(EVENT_0);
}

int main(void)
{
	os_ClrLCDFull();

	if(ev_setup(32, malloc)) return 1;
	
	size_t ev0 = 22;
	if(ev_register(EVENT_0, event0_do, &ev0, sizeof(ev0))) return 1;
	
	ev_watch(EVENT_0);
	
	some_function();
	
	ev_handle();
	
	os_GetKey();
	ev_cleanup(free);
}
