Event-Based Programming on the CE
==================================

**EVENTLIB** is a specialty library designed for integration with the TI-84+ CE toolchain that allows developers to easily implement event-based programming into their projects without needing to worry about low-level implementation details. It also allows for bugfixes, feature additions, and changes to be pushed to the library usually without requiring developers to rebuild their projects.

If this is your first introduction to the CE Toolchain, check out the `toolchain repository <https://github.com/CE-Programming/toolchain>`_ and familiarize yourself with how it works.
    
    
API Documentation
----------------------

.. code-block:: c

	#include <eventlib.h>
	
.. doxygenenum:: _ev_flags
	:project: EVENTLIB
	
.. doxygenfunction:: ev_Setup
	:project: EVENTLIB
	
.. doxygenfunction:: ev_RegisterEvent
	:project: EVENTLIB

.. doxygenfunction:: ev_UnregisterEvent
	:project: EVENTLIB
	
.. doxygenfunction:: ev_PurgeEvent
	:project: EVENTLIB
	
.. doxygenfunction:: ev_UpdateCallbackFunction
	:project: EVENTLIB
	
.. doxygenfunction:: ev_UpdateCallbackData
	:project: EVENTLIB
	
.. doxygenfunction:: ev_Watch
	:project: EVENTLIB
	
.. doxygenfunction:: ev_Unwatch
	:project: EVENTLIB
    
.. doxygenfunction:: ev_Trigger
	:project: EVENTLIB
	
.. doxygenfunction:: ev_HandleEvents
	:project: EVENTLIB
	
.. doxygenfunction:: ev_Cleanup
	:project: EVENTLIB
