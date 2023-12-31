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
	printf("\nevent0 triggered");
}

int main(void)
{

	if(!ev_Setup(malloc, free)) return 1;
	
	ev_RegisterEvent(EVENT_0, 0, event0_do, NULL, 0);
	
	os_ClrLCDFull();
	
	ev_Watch(EVENT_0);
	
	ev_Trigger(EVENT_0);
	
	// do some other stuff
	
	ev_HandleEvents();
	os_GetKey();
	
	ev_Cleanup();
}
