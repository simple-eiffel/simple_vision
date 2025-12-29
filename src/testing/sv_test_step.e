note
	description: "Single step in a test script"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TEST_STEP

create
	make

feature {NONE} -- Initialization

	make (a_action, a_target, a_value: STRING; a_wait_ms: INTEGER)
			-- Create test step.
		require
			action_not_empty: not a_action.is_empty
		do
			action := a_action
			target := a_target
			value := a_value
			wait_ms := a_wait_ms
			repeat_count := 1
		ensure
			action_set: action = a_action
			target_set: target = a_target
			value_set: value = a_value
		end

feature -- Access

	action: STRING
			-- Action to perform (click, assert_text, wait, etc.)

	target: STRING
			-- Target widget name.

	value: STRING
			-- Value for assertion or input.

	wait_ms: INTEGER
			-- Wait time in milliseconds (for wait action).

	repeat_count: INTEGER
			-- Number of times to repeat this action.

	description: STRING
			-- Human-readable description.
		attribute
			Result := ""
		end

feature -- Modification

	set_repeat (a_count: INTEGER)
			-- Set repeat count.
		require
			positive: a_count > 0
		do
			repeat_count := a_count
		ensure
			set: repeat_count = a_count
		end

	set_description (a_desc: STRING)
			-- Set description.
		do
			description := a_desc
		end

feature -- Output

	to_string: STRING
			-- String representation.
		do
			Result := action + " -> " + target
			if not value.is_empty then
				Result := Result + " = '" + value + "'"
			end
		end

invariant
	action_not_empty: not action.is_empty

end
