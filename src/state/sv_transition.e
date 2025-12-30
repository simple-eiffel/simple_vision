note
	description: "A transition between states with optional guard condition and action"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TRANSITION

create
	make

feature {NONE} -- Initialization

	make (a_event: STRING; a_from, a_to: STRING)
			-- Create transition triggered by event from one state to another.
		require
			event_not_empty: not a_event.is_empty
			from_not_empty: not a_from.is_empty
			to_not_empty: not a_to.is_empty
		do
			event := a_event
			from_state := a_from
			to_state := a_to
		ensure
			event_set: event.same_string (a_event)
			from_set: from_state.same_string (a_from)
			to_set: to_state.same_string (a_to)
		end

feature -- Access

	event: STRING
			-- Event name that triggers this transition.

	from_state: STRING
			-- Source state name.

	to_state: STRING
			-- Target state name.

feature -- Guard

	guard: detachable FUNCTION [BOOLEAN]
			-- Optional condition that must be true for transition to occur.

feature -- Guard Commands

	set_guard (a_guard: FUNCTION [BOOLEAN])
			-- Set guard condition.
		do
			guard := a_guard
		ensure
			guard_set: guard = a_guard
		end

feature -- Guard Fluent

	only_if,
	guarded_by,
	with_guard (a_guard: FUNCTION [BOOLEAN]): like Current
			-- Fluent: set guard condition for this transition.
		do
			set_guard (a_guard)
			Result := Current
		ensure
			guard_set: guard = a_guard
			result_is_current: Result = Current
		end

	is_allowed: BOOLEAN
			-- Is this transition currently allowed (guard passes)?
		do
			if attached guard as g then
				Result := g.item (Void)
			else
				Result := True -- No guard = always allowed
			end
		end

feature -- Action

	action: detachable PROCEDURE
			-- Optional action executed during transition.

feature -- Action Commands

	set_action (a_action: PROCEDURE)
			-- Set transition action.
		do
			action := a_action
		ensure
			action_set: action = a_action
		end

	execute_action
			-- Execute the transition action if defined.
		do
			if attached action as a then
				a.call (Void)
			end
		end

feature -- Action Fluent

	then_do,
	executing,
	with_action (a_action: PROCEDURE): like Current
			-- Fluent: set action to execute during this transition.
		do
			set_action (a_action)
			Result := Current
		ensure
			action_set: action = a_action
			result_is_current: Result = Current
		end

feature -- Metadata

	description: detachable STRING
			-- Optional description of this transition.

feature -- Metadata Commands

	set_description (a_desc: STRING)
			-- Set transition description.
		do
			description := a_desc
		end

feature -- Metadata Fluent

	with_description (a_desc: STRING): like Current
			-- Fluent: set description and return Current.
		do
			set_description (a_desc)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	event_not_empty: not event.is_empty
	from_not_empty: not from_state.is_empty
	to_not_empty: not to_state.is_empty

end
