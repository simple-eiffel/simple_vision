note
	description: "Fluent builder for state machine transitions"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TRANSITION_BUILDER

create
	make

feature {NONE} -- Initialization

	make (a_machine: SV_STATE_MACHINE; a_event: STRING)
			-- Create builder for transition on event.
		require
			machine_attached: a_machine /= Void
			event_not_empty: not a_event.is_empty
		do
			machine := a_machine
			event := a_event
		ensure
			machine_set: machine = a_machine
			event_set: event.same_string (a_event)
		end

feature -- Access

	machine: SV_STATE_MACHINE
			-- Target state machine.

	event: STRING
			-- Event name.

	from_state_name: detachable STRING
			-- Source state name.

	to_state_name: detachable STRING
			-- Target state name.

	transition_guard: detachable FUNCTION [BOOLEAN]
			-- Guard condition.

	transition_action: detachable PROCEDURE
			-- Transition action.

feature -- Building

	from_state (a_state_name: STRING): like Current
			-- Set source state.
		require
			name_not_empty: not a_state_name.is_empty
		do
			from_state_name := a_state_name
			Result := Current
		ensure
			from_set: attached from_state_name as f and then f.same_string (a_state_name)
			result_is_current: Result = Current
		end

	to (a_state_name: STRING): like Current
			-- Set target state.
		require
			name_not_empty: not a_state_name.is_empty
		do
			to_state_name := a_state_name
			Result := Current
		ensure
			to_set: attached to_state_name as t and then t.same_string (a_state_name)
			result_is_current: Result = Current
		end

	only_if (a_guard: FUNCTION [BOOLEAN]): like Current
			-- Set guard condition.
		require
			guard_attached: a_guard /= Void
		do
			transition_guard := a_guard
			Result := Current
		ensure
			guard_set: transition_guard = a_guard
			result_is_current: Result = Current
		end

	do_action (a_action: PROCEDURE): like Current
			-- Set transition action.
		require
			action_attached: a_action /= Void
		do
			transition_action := a_action
			Result := Current
		ensure
			action_set: transition_action = a_action
			result_is_current: Result = Current
		end

	apply: SV_STATE_MACHINE
			-- Build and add the transition to the machine.
		require
			from_defined: attached from_state_name
			to_defined: attached to_state_name
		local
			l_transition: SV_TRANSITION
		do
			check attached from_state_name as f and attached to_state_name as t then
				create l_transition.make (event, f, t)
				if attached transition_guard as g then
					if attached l_transition.set_guard (g) then end
				end
				if attached transition_action as a then
					if attached l_transition.set_action (a) then end
				end
				if attached machine.add_transition (l_transition) then end
			end
			Result := machine
		end

feature -- Shorthand

	goes_to (a_state_name: STRING): SV_STATE_MACHINE
			-- Shorthand: set target and apply (assumes current state as source).
		require
			name_not_empty: not a_state_name.is_empty
		do
			if attached machine.current_state as cs then
				from_state_name := cs.name
			end
			to_state_name := a_state_name
			Result := apply
		end

end
