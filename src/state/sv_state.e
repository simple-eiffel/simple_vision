note
	description: "A single state in a state machine with entry/exit actions"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_STATE

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create state with name.
		require
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			create allowed_transitions.make (5)
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Identity

	name: STRING
			-- State identifier.

feature -- Actions

	on_enter: detachable PROCEDURE
			-- Action executed when entering this state.

	on_exit: detachable PROCEDURE
			-- Action executed when leaving this state.

	set_on_enter (a_action: PROCEDURE): like Current
			-- Set entry action.
		do
			on_enter := a_action
			Result := Current
		ensure
			action_set: on_enter = a_action
			result_is_current: Result = Current
		end

	set_on_exit (a_action: PROCEDURE): like Current
			-- Set exit action.
		do
			on_exit := a_action
			Result := Current
		ensure
			action_set: on_exit = a_action
			result_is_current: Result = Current
		end

	enter_action (a_action: PROCEDURE): like Current
			-- Fluent alias for set_on_enter.
		do
			Result := set_on_enter (a_action)
		ensure
			result_is_current: Result = Current
		end

	exit_action (a_action: PROCEDURE): like Current
			-- Fluent alias for set_on_exit.
		do
			Result := set_on_exit (a_action)
		ensure
			result_is_current: Result = Current
		end

feature -- Transitions

	allowed_transitions: ARRAYED_LIST [STRING]
			-- Names of states we can transition TO from this state.

	allow_transition_to (a_state_name: STRING): like Current
			-- Allow transition to named state.
		require
			name_not_empty: not a_state_name.is_empty
		do
			if not allowed_transitions.has (a_state_name) then
				allowed_transitions.extend (a_state_name)
			end
			Result := Current
		ensure
			allowed: allowed_transitions.has (a_state_name)
			result_is_current: Result = Current
		end

	can_transition_to (a_state_name: STRING): BOOLEAN
			-- Is transition to named state allowed?
		require
			name_not_empty: not a_state_name.is_empty
		do
			Result := allowed_transitions.has (a_state_name)
		end

	allows (a_state_name: STRING): like Current
			-- Fluent alias for allow_transition_to.
		require
			name_not_empty: not a_state_name.is_empty
		do
			Result := allow_transition_to (a_state_name)
		ensure
			result_is_current: Result = Current
		end

feature -- Metadata

	description: detachable STRING
			-- Optional description of this state.

	set_description (a_desc: STRING): like Current
			-- Set state description.
		do
			description := a_desc
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	described_as (a_desc: STRING): like Current
			-- Fluent alias for set_description.
		do
			Result := set_description (a_desc)
		ensure
			result_is_current: Result = Current
		end

invariant
	name_not_empty: not name.is_empty
	transitions_exist: allowed_transitions /= Void

end
