Event-Based Programming on the CE
==================================

**EVENTLIB** is a specialty library designed for integration with the TI-84+ CE toolchain that allows developers to easily implement event-based programming into their projects without needing to worry about low-level implementation details. It also allows for bugfixes, feature additions, and changes to be pushed to the library usually without requiring developers to rebuild their projects.

If this is your first introduction to the CE Toolchain, check out the `toolchain repository <https://github.com/CE-Programming/toolchain>`_ and familiarize yourself with how it works.
    
    
API Documentation
----------------------

.. code-block:: c

	#include <eventlib.h>


.. doxygenenum:: ev_status_t
	:project: EVENTLIB
	
.. doxygenenum:: _ev_flags
	:project: EVENTLIB
	
.. doxygenfunction:: ev_setup
	:project: EVENTLIB
	
.. doxygenfunction:: ev_register
	:project: EVENTLIB

.. doxygenfunction:: ev_unregister
	:project: EVENTLIB
	
.. doxygenfunction:: ev_watch
	:project: EVENTLIB
	
.. doxygenfunction:: ev_unwatch
	:project: EVENTLIB
    
.. doxygenfunction:: ev_trigger
	:project: EVENTLIB
	
.. doxygenfunction:: ev_handle
	:project: EVENTLIB
	
.. doxygenfunction:: ev_cleanup
	:project: EVENTLIB
