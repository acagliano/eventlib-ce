
#ifndef eventlib_h
#define eventlib_h

#include <stdint.h>
#include <stdbool.h>

typedef int event_t;

/// Defines flags that can be passed to @b ev_register.
enum _ev_flags {
	EV_WATCHER_ENABLE	= 0b1,		/**< Enables the watcher upon registration, eliminating need for @b ev_watch.*/
	EV_WATCHER_NOENABLE		= 0,	/**< Does not enable watcher upon registration, @b ev_watch needed to enable.*/
	EV_DISABLE_AFTER_RUN	= 0b10,	/**< Disables watcher for this event binding upon callback completion. */
	EV_PERSIST_AFTER_RUN	= 0,	/**< Persist the watcher for this event binding upon callback completion. */
};

/**
 @brief Initialzes the events system, allocates an array of structs for registered events, and saves pointer to malloc/free.
 @param max_events	Maximum number of events that can be logged.
 @param malloc		Pointer to toolchain @b malloc function.
 @param free		Pointer to toolchain @b free function.
 @returns			Returns status of events initialization.
 */
bool ev_Setup(void* (*malloc)(size_t), void (*free)(void*));

/**
 @brief Registers an event callback bound to a specific event ID, registers any associated data.
 @param event_id	Event identifier to bind.
 @param ev_flags	Bitwise OR of event flags (see @b _ev_flags).
 @param callback	Pointer to function to execute if event is triggered.
 @param callback_data	Pointer to data that should be passed to the callback.
 @param callback_data_len	Length of data that should be passed to the callback.
 @returns		Slot number to which event is bound (for use with unregister and edit callbacks), or -1 for failure.
 @note Functions compatible with this API should bear the following signature:
	@code void function(void* data, size_t len); @endcode
 @note It is possible to register multiple callbacks to the same event by calling register with the same @b event_id and
	and different callback parameters.
 @note This function passes the data by copy, not by reference, as there is no way to ensure the data is in scope at the
	time the event callback would trigger. @b malloc is used to allocate a buffer for a copy of the callback data and that
	pointer is placed into the event metadata.
 */
event_t ev_RegisterEvent(uint8_t event_id,
					  uint8_t ev_flags,
					  void (*callback)(void*, size_t),
					  void *callback_data, size_t callback_data_len);

/**
 @brief Deletes a specific event registration by slot number.
 @param ev_slot		Event registration to delete.
 @returns		Returns status of deletion.
 */
bool ev_UnregisterEvent(event_t ev_slot);

/**
 @brief Updates the callback function address for the specific event registration.
 @param ev_slot		Event registration to update.
 @param callback	New pointer for callback function to update.
 @returns		Returns status of callback update.
 */
bool ev_UpdateCallbackFunction(event_t ev_slot, void (*callback)(void*, size_t));

/**
 @brief Updates the callback data for specific event registration. Adjusts allocation if necessary.
 @param ev_slot		Event registration to update.
 @param callback_data	Pointer to data to replace queued data with.
 @param callback_data_len	Length of data to overwrite.
 @param realloc		Pointer to toolchain @b realloc function.
 @returns		Returns status of callback update.
 @note Passing @b callback_data_len == 0 should remove any
	associated data and set internal data pointer to NULL.
 @note Prior allocation and data should be preserved if new allocation fails.
 */
bool ev_UpdateCallbackData(event_t ev_slot,
						   void* callback_data, size_t callback_data_len,
						   void* (*realloc)(void*, size_t));

/**
 @brief Purges up to @b count bindings for an event, starting from the earliest.
 @param event_id	Event identifier to delete binding(s) for.
 @param count			Maximum number of bindings to delete.
 */
void ev_PurgeEvent(uint8_t event_id, uint8_t count);

/**
 @brief Enables watchers for an event ID.
 @param event_id	Event ID to enable watchers for.
 @returns		Returns status of watcher activation.
 @note Enables watchers for all registered events with the same ID.
 @note If @b ev_register is called with @b enable_watcher=True, you do not need to call this function.
 */
void ev_Watch(uint8_t event_id);

/**
 @brief Disables watchers for an event ID.
 @param event_id	Event ID to disable watchers for.
 @returns		Returns status of watcher deactivation.
 @note Disables watchers for all registered events with the same ID.
 */
void ev_Unwatch(uint8_t event_id);

/**
 @brief Triggers event by ID
 @param event_id	Informs watcher that indicated event occurred.
 @returns 		Returns status of event trigger.
 */
void ev_Trigger(uint8_t event_id);

/**
 @brief Polls all event watchers and executes callbacks for any events that have occurred.
 @returns		Returns status of event handler callback execution.
 */
void ev_HandleEvents(void);

/**
 @brief Cleans up all allocated @b callback_data blocks.
 */
void ev_Cleanup(void);

#endif
