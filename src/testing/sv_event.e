note
	description: "Event record for GUI testing harness"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_EVENT

create
	make,
	make_click,
	make_key,
	make_state_change

feature {NONE} -- Initialization

	make (a_type: like event_type; a_details: like details)
			-- Create event with type and details.
		require
			type_not_empty: not a_type.is_empty
		do
			event_type := a_type
			details := a_details
			create timestamp.make_now
		ensure
			type_set: event_type = a_type
			details_set: details = a_details
		end

	make_click
			-- Create click event.
		do
			make (Event_click, "")
		end

	make_key (a_key_code: INTEGER; a_text: STRING)
			-- Create key event.
		do
			make (Event_key, "code=" + a_key_code.out + ",text=" + a_text)
		end

	make_state_change (a_property, a_old_value, a_new_value: STRING)
			-- Create state change event.
		do
			make (Event_state_change, a_property + ":" + a_old_value + "->" + a_new_value)
		end

feature -- Access

	event_type: STRING
			-- Type of event (click, key, state_change, etc.)

	details: STRING
			-- Event-specific details.

	timestamp: DATE_TIME
			-- When event occurred.

feature -- Event Types

	Event_click: STRING = "click"
	Event_double_click: STRING = "double_click"
	Event_key: STRING = "key"
	Event_focus: STRING = "focus"
	Event_blur: STRING = "blur"
	Event_state_change: STRING = "state_change"
	Event_show: STRING = "show"
	Event_hide: STRING = "hide"

feature -- Query

	is_click: BOOLEAN
			-- Is this a click event?
		do
			Result := event_type.same_string (Event_click)
		end

	is_key: BOOLEAN
			-- Is this a key event?
		do
			Result := event_type.same_string (Event_key)
		end

feature -- Output

	to_string: STRING
			-- String representation.
		do
			Result := "[" + timestamp.out + "] " + event_type
			if not details.is_empty then
				Result := Result + " (" + details + ")"
			end
		end

invariant
	event_type_not_empty: not event_type.is_empty
	timestamp_exists: timestamp /= Void

end
