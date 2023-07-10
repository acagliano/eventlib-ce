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

#define CEMU_CONSOLE ((char*)0xFB0000)
#define EVENT_0		0

void event0_do(void* data, size_t len){
	printf("\nevent0 triggered");
}

void event0_do2(void* data, size_t len){
	printf("\nevent0 #2 triggered");
}

int main(void)
{

	if(!ev_Setup(malloc, free)) return 1;
	
	event_t bind1 = ev_RegisterEvent(EVENT_0, EV_WATCHER_ENABLE, event0_do, NULL, 0);
	event_t bind2 = ev_RegisterEvent(EVENT_0, EV_WATCHER_ENABLE, event0_do2, NULL, 0);
	
	os_ClrLCDFull();
	
	ev_Trigger(EVENT_0);
	
	// do some other stuff
	
	ev_HandleEvents();
	os_GetKey();
	
	os_ClrLCDFull();
	ev_UnregisterEvent(bind1);
	ev_UpdateCallbacks(bind2, event0_do, NULL, 0, realloc);
	
	ev_Trigger(EVENT_0);
	
	// do some other stuff
	
	ev_HandleEvents();
	os_GetKey();
	
	event_t bind3 = ev_RegisterEvent(EVENT_0, EV_WATCHER_ENABLE, event0_do2, NULL, 0);
	sprintf(CEMU_CONSOLE, "%u\n", bind3);
	
	ev_Cleanup();
}
