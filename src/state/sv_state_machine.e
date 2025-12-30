note
	description: "State machine for UI state management - can be defined from JSON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_STATE_MACHINE

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create named state machine.
		require
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			create states.make (10)
			create transitions.make (20)
			create transition_history.make (50)
			create state_change_actions.make
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Identity

	name: STRING
			-- State machine identifier.

feature -- State Management

	states: HASH_TABLE [SV_STATE, STRING]
			-- All states by name.

	current_state: detachable SV_STATE
			-- Current active state.

	current_state_name: STRING
			-- Name of current state (empty if none).
		do
			if attached current_state as cs then
				Result := cs.name
			else
				Result := ""
			end
		end

	initial_state: detachable STRING
			-- Name of initial state.

	add_state (a_state: SV_STATE)
			-- Add state to machine.
		require
			state_attached: a_state /= Void
			unique_name: not states.has (a_state.name)
		do
			states.put (a_state, a_state.name)
		ensure
			state_added: states.has (a_state.name)
		end

	with_state (a_state: SV_STATE): like Current
			-- Fluent: add state and return Current.
		require
			state_attached: a_state /= Void
			unique_name: not states.has (a_state.name)
		do
			add_state (a_state)
			Result := Current
		ensure
			state_added: states.has (a_state.name)
			result_is_current: Result = Current
		end

	state (a_name: STRING): SV_STATE
			-- Create and add a new state with given name.
		require
			name_not_empty: not a_name.is_empty
		local
			l_state: SV_STATE
		do
			if attached states.item (a_name) as existing then
				Result := existing
			else
				create l_state.make (a_name)
				states.put (l_state, a_name)
				Result := l_state
			end
		ensure
			state_exists: states.has (a_name)
		end

	has_state (a_name: STRING): BOOLEAN
			-- Does machine have state with this name?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := states.has (a_name)
		end

	set_initial (a_state_name: STRING)
			-- Set initial state.
		require
			state_exists: has_state (a_state_name)
		do
			initial_state := a_state_name
		ensure
			initial_set: attached initial_state as i and then i.same_string (a_state_name)
		end

	with_initial (a_state_name: STRING): like Current
			-- Fluent: set initial state and return Current.
		require
			state_exists: has_state (a_state_name)
		do
			set_initial (a_state_name)
			Result := Current
		ensure
			initial_set: attached initial_state as i and then i.same_string (a_state_name)
			result_is_current: Result = Current
		end

	start
			-- Start the machine in initial state.
		require
			initial_defined: attached initial_state
			initial_exists: attached initial_state as i and then has_state (i)
		do
			if attached initial_state as i and then attached states.item (i) as s then
				enter_state (s)
			end
		ensure
			in_initial_state: attached initial_state as i and then current_state_name.same_string (i)
		end

	reset
			-- Reset to initial state.
		do
			if attached current_state as cs and then attached cs.on_exit as ex then
				ex.call (Void)
			end
			current_state := Void
			transition_history.wipe_out
			if attached initial_state then
				start
			end
		end

feature -- Transitions

	transitions: ARRAYED_LIST [SV_TRANSITION]
			-- All defined transitions.

	add_transition (a_transition: SV_TRANSITION)
			-- Add transition to machine.
		require
			transition_attached: a_transition /= Void
			from_state_exists: has_state (a_transition.from_state)
			to_state_exists: has_state (a_transition.to_state)
		do
			transitions.extend (a_transition)
			-- Also update the state's allowed transitions
			if attached states.item (a_transition.from_state) as from_s then
				from_s.allowed_transitions.extend (a_transition.to_state)
			end
		ensure
			transition_added: transitions.has (a_transition)
		end

	with_transition (a_transition: SV_TRANSITION): like Current
			-- Fluent: add transition and return Current.
		require
			transition_attached: a_transition /= Void
			from_state_exists: has_state (a_transition.from_state)
			to_state_exists: has_state (a_transition.to_state)
		do
			add_transition (a_transition)
			Result := Current
		ensure
			transition_added: transitions.has (a_transition)
			result_is_current: Result = Current
		end

	on (a_event: STRING): SV_TRANSITION_BUILDER
			-- Start building a transition for event.
		require
			event_not_empty: not a_event.is_empty
		do
			create Result.make (Current, a_event)
		end

	trigger (a_event: STRING): BOOLEAN
			-- Trigger event, potentially causing state transition.
			-- Returns True if transition occurred.
		require
			event_not_empty: not a_event.is_empty
			machine_started: is_started
		local
			l_transition: detachable SV_TRANSITION
		do
			l_transition := find_transition (a_event)
			if attached l_transition as t then
				if t.is_allowed then
					log_transition (a_event, current_state_name, t.to_state, True)
					execute_transition (t)
					Result := True
				else
					log_transition (a_event, current_state_name, t.to_state, False)
				end
			else
				log_no_transition (a_event, current_state_name)
			end
		end

	can_trigger (a_event: STRING): BOOLEAN
			-- Can this event be triggered in current state?
		require
			event_not_empty: not a_event.is_empty
			machine_started: is_started
		local
			l_transition: detachable SV_TRANSITION
		do
			l_transition := find_transition (a_event)
			Result := attached l_transition as t and then t.is_allowed
		end

feature -- State Queries

	is_in (a_state_name: STRING): BOOLEAN
			-- Is machine in named state?
		require
			name_not_empty: not a_state_name.is_empty
		do
			Result := current_state_name.same_string (a_state_name)
		end

	is_started: BOOLEAN
			-- Has machine been started?
		do
			Result := attached current_state
		end

feature -- History

	transition_history: ARRAYED_LIST [TUPLE [from_state, to_state, event: STRING; timestamp: DATE_TIME]]
			-- Record of all transitions.

	last_event: STRING
			-- Most recent event triggered.
		do
			if transition_history.is_empty then
				Result := ""
			else
				Result := transition_history.last.event
			end
		end

	previous_state_name: STRING
			-- State before current (empty if none).
		do
			if transition_history.count >= 1 then
				Result := transition_history.last.from_state
			else
				Result := ""
			end
		end

feature -- Events

	state_change_actions: ACTION_SEQUENCE [TUPLE [from_state, to_state: STRING]]
			-- Actions called on any state change.

	add_state_change_action (a_action: PROCEDURE [TUPLE [STRING, STRING]])
			-- Add action for state changes.
		require
			action_attached: a_action /= Void
		do
			state_change_actions.extend (a_action)
		end

	on_state_change (a_action: PROCEDURE [TUPLE [STRING, STRING]]): like Current
			-- Fluent: add state change action and return Current.
		require
			action_attached: a_action /= Void
		do
			add_state_change_action (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Validation

	is_valid: BOOLEAN
			-- Is machine properly configured?
		do
			Result := not states.is_empty and then
					  attached initial_state as i and then
					  has_state (i)
		end

	validate: ARRAYED_LIST [STRING]
			-- Return list of validation errors (empty if valid).
		do
			create Result.make (5)
			if states.is_empty then
				Result.extend ("No states defined")
			end
			if not attached initial_state then
				Result.extend ("No initial state set")
			elseif attached initial_state as i and then not has_state (i) then
				Result.extend ("Initial state '" + i + "' does not exist")
			end
			-- Check all transitions reference valid states
			across transitions as t loop
				if not has_state (t.item.from_state) then
					Result.extend ("Transition from unknown state: " + t.item.from_state)
				end
				if not has_state (t.item.to_state) then
					Result.extend ("Transition to unknown state: " + t.item.to_state)
				end
			end
		end

feature -- Pathway Analysis (for testing)

	all_state_names: ARRAYED_LIST [STRING]
			-- List of all state names.
		do
			create Result.make (states.count)
			across states as s loop
				Result.extend (s.key)
			end
		end

	all_events: ARRAYED_LIST [STRING]
			-- List of all unique event names.
		local
			l_seen: HASH_TABLE [BOOLEAN, STRING]
		do
			create Result.make (transitions.count)
			create l_seen.make (transitions.count)
			across transitions as t loop
				if not l_seen.has (t.item.event) then
					l_seen.put (True, t.item.event)
					Result.extend (t.item.event)
				end
			end
		end

	reachable_states_from (a_state_name: STRING): ARRAYED_LIST [STRING]
			-- States directly reachable from given state.
		require
			state_exists: has_state (a_state_name)
		do
			create Result.make (5)
			across transitions as t loop
				if t.item.from_state.same_string (a_state_name) then
					if not Result.has (t.item.to_state) then
						Result.extend (t.item.to_state)
					end
				end
			end
		end

	events_from (a_state_name: STRING): ARRAYED_LIST [STRING]
			-- Events available from given state.
		require
			state_exists: has_state (a_state_name)
		do
			create Result.make (5)
			across transitions as t loop
				if t.item.from_state.same_string (a_state_name) then
					if not Result.has (t.item.event) then
						Result.extend (t.item.event)
					end
				end
			end
		end

feature -- Logging

	is_logging_enabled: BOOLEAN
			-- Is transition logging enabled?
			-- Enable for debugging and testing.

	enable_logging
			-- Enable transition logging.
		do
			is_logging_enabled := True
		ensure
			logging_enabled: is_logging_enabled
		end

	disable_logging
			-- Disable transition logging.
		do
			is_logging_enabled := False
		ensure
			logging_disabled: not is_logging_enabled
		end

	last_log_message: STRING
			-- Most recent log message (for testing).
		attribute
			Result := ""
		end

feature {NONE} -- Logging Implementation

	log_transition (a_event, a_from, a_to: STRING; a_allowed: BOOLEAN)
			-- Log a transition attempt.
		require
			event_not_empty: not a_event.is_empty
		do
			if a_allowed then
				last_log_message := "[" + name + "] " + a_event + ": " + a_from + " -> " + a_to
			else
				last_log_message := "[" + name + "] " + a_event + ": " + a_from + " -> " + a_to + " (BLOCKED by guard)"
			end
			if is_logging_enabled then
				debug_log (last_log_message)
			end
		end

	log_no_transition (a_event, a_from: STRING)
			-- Log when no transition found for event.
		require
			event_not_empty: not a_event.is_empty
		do
			last_log_message := "[" + name + "] " + a_event + ": no transition from " + a_from
			if is_logging_enabled then
				debug_log (last_log_message)
			end
		end

feature {NONE} -- Implementation

	find_transition (a_event: STRING): detachable SV_TRANSITION
			-- Find transition for event from current state.
		do
			if attached current_state as cs then
				across transitions as t loop
					if t.item.event.same_string (a_event) and then
					   t.item.from_state.same_string (cs.name) then
						Result := t.item
					end
				end
			end
		end

	execute_transition (a_transition: SV_TRANSITION)
			-- Execute transition: exit old state, run action, enter new state.
		require
			transition_attached: a_transition /= Void
			to_state_exists: has_state (a_transition.to_state)
		local
			l_from_name: STRING
			l_now: DATE_TIME
		do
			l_from_name := current_state_name

			-- Exit current state
			if attached current_state as cs and then attached cs.on_exit as ex then
				ex.call (Void)
			end

			-- Execute transition action
			a_transition.execute_action

			-- Enter new state
			if attached states.item (a_transition.to_state) as new_state then
				enter_state (new_state)
			end

			-- Record history
			create l_now.make_now
			transition_history.extend ([l_from_name, a_transition.to_state, a_transition.event, l_now])

			-- Fire state change event
			state_change_actions.call ([l_from_name, a_transition.to_state])
		end

	enter_state (a_state: SV_STATE)
			-- Enter a state, executing its entry action.
		require
			state_attached: a_state /= Void
		do
			current_state := a_state
			if attached a_state.on_enter as en then
				en.call (Void)
			end
		ensure
			state_entered: current_state = a_state
		end

invariant
	name_not_empty: not name.is_empty
	states_exist: states /= Void
	transitions_exist: transitions /= Void

end
