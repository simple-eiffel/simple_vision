note
	description: "GUI testing harness - like EiffelStudio's W_code debugger for widgets"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TEST_HARNESS

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create test harness.
		do
			create recorded_events.make (100)
			create registered_widgets.make (20)
			create assertions.make (50)
			create script_steps.make (0)
			is_recording := False
			step_delay_ms := 100
		end

feature -- Access

	recorded_events: ARRAYED_LIST [TUPLE [widget: SV_WIDGET; event: SV_EVENT]]
			-- Events recorded during test.

	registered_widgets: HASH_TABLE [SV_WIDGET, STRING]
			-- Widgets registered by name for script lookup.

	assertions: ARRAYED_LIST [TUPLE [passed: BOOLEAN; description: STRING]]
			-- Assertion results.

	script_steps: ARRAYED_LIST [SV_TEST_STEP]
			-- Loaded script steps.

	current_step: INTEGER
			-- Current step index during playback.

	step_delay_ms: INTEGER
			-- Delay between steps in milliseconds.

feature -- Status

	is_recording: BOOLEAN
			-- Are we recording events?

	is_playing: BOOLEAN
			-- Are we playing a script?

	all_assertions_passed: BOOLEAN
			-- Did all assertions pass?
		do
			Result := assertions.for_all (agent (a: TUPLE [passed: BOOLEAN; description: STRING]): BOOLEAN
				do
					Result := a.passed
				end)
		end

	failed_assertion_count: INTEGER
			-- Number of failed assertions.
		do
			across assertions as a loop
				if not a.item.passed then
					Result := Result + 1
				end
			end
		end

feature -- Widget Registration

	register (a_widget: SV_WIDGET; a_name: STRING)
			-- Register widget for script lookup.
		require
			widget_attached: a_widget /= Void
			name_not_empty: not a_name.is_empty
		do
			registered_widgets.put (a_widget, a_name)
			a_widget.attach_harness (Current)
		ensure
			registered: registered_widgets.has (a_name)
		end

	widget (a_name: STRING): detachable SV_WIDGET
			-- Look up registered widget by name.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := registered_widgets.item (a_name)
		end

feature -- Recording

	start_recording
			-- Begin recording events.
		do
			is_recording := True
			recorded_events.wipe_out
			debug_log ("Started recording")
		ensure
			recording: is_recording
		end

	stop_recording
			-- Stop recording events.
		do
			is_recording := False
			debug_log ("Stopped recording. " + recorded_events.count.out + " events captured.")
		ensure
			not_recording: not is_recording
		end

	record_event (a_widget: SV_WIDGET; a_event: SV_EVENT)
			-- Record event from widget (called by widget instrumentation).
		require
			widget_attached: a_widget /= Void
			event_attached: a_event /= Void
		do
			if is_recording then
				recorded_events.extend ([a_widget, a_event])
				debug_log ("Recorded: " + a_event.to_string)
			end
		end

feature -- Event Injection

	simulate_click (a_widget: SV_WIDGET)
			-- Simulate mouse click on widget.
		require
			widget_attached: a_widget /= Void
		do
			debug_log ("Simulating click on widget")
			-- For EV_BUTTON, trigger select_actions
			if attached {SV_BUTTON} a_widget as btn then
				btn.ev_button.select_actions.call (Void)
			end
			-- Record the simulated event
			record_event (a_widget, create {SV_EVENT}.make_click)
		end

	simulate_click_by_name (a_name: STRING)
			-- Simulate click on registered widget.
		require
			name_not_empty: not a_name.is_empty
		do
			if attached widget (a_name) as w then
				simulate_click (w)
			else
				record_assertion (False, "Widget not found: " + a_name)
			end
		end

	simulate_key_sequence (a_widget: SV_WIDGET; a_text: STRING)
			-- Simulate typing text into widget.
		require
			widget_attached: a_widget /= Void
			text_not_void: a_text /= Void
		do
			debug_log ("Simulating key sequence: " + a_text)
			-- For text widgets, could update text directly
			-- For now, just record the event
			record_event (a_widget, create {SV_EVENT}.make_key (0, a_text))
		end

	simulate_type (a_widget: SV_WIDGET; a_text: STRING)
			-- Simulate typing text into a text input widget (actually sets text).
		require
			widget_attached: a_widget /= Void
			text_not_void: a_text /= Void
		do
			debug_log ("Simulating type: " + a_text)
			if attached {SV_TEXT_FIELD} a_widget as tf then
				tf.set_text (a_text)
			elseif attached {SV_MASKED_FIELD} a_widget as mf then
				mf.set_text (a_text)
			elseif attached {SV_PASSWORD_FIELD} a_widget as pf then
				pf.set_text (a_text)
			end
			record_event (a_widget, create {SV_EVENT}.make_key (0, a_text))
		end

	simulate_type_by_name (a_name: STRING; a_text: STRING)
			-- Simulate typing into registered widget by name.
		require
			name_not_empty: not a_name.is_empty
			text_not_void: a_text /= Void
		do
			if attached widget (a_name) as w then
				simulate_type (w, a_text)
			else
				record_assertion (False, "Widget not found: " + a_name)
			end
		end

	simulate_select (a_widget: SV_WIDGET; a_index: INTEGER)
			-- Simulate selecting item at index in dropdown/list.
		require
			widget_attached: a_widget /= Void
			valid_index: a_index >= 1
		do
			debug_log ("Simulating select index: " + a_index.out)
			if attached {SV_DROPDOWN} a_widget as dd then
				dd.select_index (a_index)
			end
			record_event (a_widget, create {SV_EVENT}.make_state_change ("selection", "", a_index.out))
		end

	simulate_check (a_widget: SV_WIDGET; a_checked: BOOLEAN)
			-- Simulate checking/unchecking a checkbox.
		require
			widget_attached: a_widget /= Void
		do
			debug_log ("Simulating check: " + a_checked.out)
			if attached {SV_CHECKBOX} a_widget as cb then
				if a_checked then cb.check_now else cb.uncheck_now end
			end
			record_event (a_widget, create {SV_EVENT}.make_state_change ("checked", "", a_checked.out))
		end

feature -- Assertions

	assert_text (a_widget: SV_TEXT; a_expected: STRING): BOOLEAN
			-- Assert widget has expected text.
		require
			widget_attached: a_widget /= Void
		local
			l_actual: STRING_32
		do
			l_actual := a_widget.text
			Result := l_actual.same_string_general (a_expected)
			record_assertion (Result, "assert_text: expected '" + a_expected + "', got '" + l_actual.to_string_8 + "'")
		end

	assert_text_by_name (a_name: STRING; a_expected: STRING): BOOLEAN
			-- Assert registered text widget has expected text.
		require
			name_not_empty: not a_name.is_empty
		do
			if attached {SV_TEXT} widget (a_name) as txt then
				Result := assert_text (txt, a_expected)
			else
				Result := False
				record_assertion (False, "Widget not found or not SV_TEXT: " + a_name)
			end
		end

	assert_visible (a_widget: SV_WIDGET): BOOLEAN
			-- Assert widget is visible.
		require
			widget_attached: a_widget /= Void
		do
			Result := a_widget.is_visible
			record_assertion (Result, "assert_visible: widget " + (if Result then "is" else "is NOT" end) + " visible")
		end

	assert_enabled (a_widget: SV_WIDGET): BOOLEAN
			-- Assert widget is enabled.
		require
			widget_attached: a_widget /= Void
		do
			Result := a_widget.is_enabled
			record_assertion (Result, "assert_enabled: widget " + (if Result then "is" else "is NOT" end) + " enabled")
		end

	record_assertion (a_passed: BOOLEAN; a_description: STRING)
			-- Record assertion result.
		do
			assertions.extend ([a_passed, a_description])
			if a_passed then
				debug_log ("PASS: " + a_description)
			else
				debug_log ("FAIL: " + a_description)
			end
		end

feature -- Script Loading

	load_script_from_json (a_json: STRING)
			-- Load test steps from JSON string.
		require
			json_not_empty: not a_json.is_empty
		local
			l_parser: SV_TEST_SCRIPT_PARSER
		do
			create l_parser.make
			script_steps := l_parser.parse (a_json)
			current_step := 0
			debug_log ("Loaded " + script_steps.count.out + " steps from script")
		end

feature -- Script Playback

	play
			-- Execute all steps in loaded script.
		do
			is_playing := True
			from current_step := 1 until current_step > script_steps.count or not is_playing loop
				execute_step (script_steps [current_step])
				wait (step_delay_ms)
				current_step := current_step + 1
			end
			is_playing := False
			debug_log ("Playback complete. " + passed_count.out + "/" + assertions.count.out + " assertions passed.")
		end

	step
			-- Execute next step only.
		do
			if current_step < script_steps.count then
				current_step := current_step + 1
				execute_step (script_steps [current_step])
			end
		end

	stop
			-- Stop playback.
		do
			is_playing := False
		ensure
			stopped: not is_playing
		end

feature -- Results

	passed_count: INTEGER
			-- Number of passed assertions.
		do
			across assertions as a loop
				if a.item.passed then
					Result := Result + 1
				end
			end
		end

	report: STRING
			-- Generate test report.
		do
			create Result.make (500)
			Result.append ("=== Test Report ===%N")
			Result.append ("Assertions: " + passed_count.out + "/" + assertions.count.out + " passed%N")
			Result.append ("%N--- Details ---%N")
			across assertions as a loop
				Result.append ((if a.item.passed then "[PASS] " else "[FAIL] " end) + a.item.description + "%N")
			end
		end

feature -- State Machine Testing

	register_state_machine (a_machine: SV_STATE_MACHINE; a_name: STRING)
			-- Register state machine for testing.
		require
			machine_attached: a_machine /= Void
			name_not_empty: not a_name.is_empty
		do
			if not attached state_machines then
				create state_machines.make (5)
			end
			if attached state_machines as sm then
				sm.put (a_machine, a_name)
			end
		ensure
			registered: attached state_machines as sm and then sm.has (a_name)
		end

	state_machine (a_name: STRING): detachable SV_STATE_MACHINE
			-- Get registered state machine.
		require
			name_not_empty: not a_name.is_empty
		do
			if attached state_machines as sm then
				Result := sm.item (a_name)
			end
		end

	assert_state (a_machine_name: STRING; a_expected_state: STRING): BOOLEAN
			-- Assert state machine is in expected state.
		require
			machine_name_not_empty: not a_machine_name.is_empty
			state_not_empty: not a_expected_state.is_empty
		do
			if attached state_machine (a_machine_name) as sm then
				Result := sm.is_in (a_expected_state)
				record_assertion (Result,
					"assert_state: " + a_machine_name + " expected '" + a_expected_state +
					"', actual '" + sm.current_state_name + "'")
			else
				Result := False
				record_assertion (False, "State machine not found: " + a_machine_name)
			end
		end

	trigger_event (a_machine_name: STRING; a_event: STRING): BOOLEAN
			-- Trigger event on state machine, return True if transition occurred.
		require
			machine_name_not_empty: not a_machine_name.is_empty
			event_not_empty: not a_event.is_empty
		do
			if attached state_machine (a_machine_name) as sm then
				Result := sm.trigger (a_event)
				debug_log ("Triggered '" + a_event + "' on " + a_machine_name +
					": " + (if Result then "transitioned" else "no transition" end))
			else
				debug_log ("State machine not found: " + a_machine_name)
			end
		end

	test_all_pathways (a_machine: SV_STATE_MACHINE): ARRAYED_LIST [TUPLE [path: ARRAYED_LIST [STRING]; success: BOOLEAN]]
			-- Test all possible pathways through state machine.
			-- Returns list of paths with success/failure status.
		require
			machine_attached: a_machine /= Void
			machine_valid: a_machine.is_valid
		local
			l_paths: ARRAYED_LIST [ARRAYED_LIST [STRING]]
			l_path: ARRAYED_LIST [STRING]
		do
			create Result.make (20)
			l_paths := enumerate_paths (a_machine)

			across l_paths as path loop
				l_path := path.item
				a_machine.reset
				Result.extend ([l_path, execute_path (a_machine, l_path)])
			end
		end

	pathway_coverage_report (a_machine: SV_STATE_MACHINE): STRING
			-- Generate pathway coverage report.
		require
			machine_attached: a_machine /= Void
		local
			l_results: ARRAYED_LIST [TUPLE [path: ARRAYED_LIST [STRING]; success: BOOLEAN]]
			l_passed, l_total: INTEGER
		do
			l_results := test_all_pathways (a_machine)
			l_total := l_results.count

			create Result.make (500)
			Result.append ("=== Pathway Coverage Report ===%N")
			Result.append ("State Machine: " + a_machine.name + "%N")
			Result.append ("States: " + a_machine.states.count.out + "%N")
			Result.append ("Transitions: " + a_machine.transitions.count.out + "%N")
			Result.append ("%N--- Pathways Tested ---%N")

			across l_results as r loop
				if r.item.success then
					l_passed := l_passed + 1
					Result.append ("[PASS] ")
				else
					Result.append ("[FAIL] ")
				end
				Result.append (path_to_string (r.item.path) + "%N")
			end

			Result.append ("%N--- Summary ---%N")
			Result.append ("Pathways: " + l_passed.out + "/" + l_total.out + " passed%N")
		end

feature {NONE} -- State Machine Testing Implementation

	state_machines: detachable HASH_TABLE [SV_STATE_MACHINE, STRING]
			-- Registered state machines.

	enumerate_paths (a_machine: SV_STATE_MACHINE): ARRAYED_LIST [ARRAYED_LIST [STRING]]
			-- Enumerate all simple paths from initial state (limited depth).
		local
			l_path: ARRAYED_LIST [STRING]
			l_visited: HASH_TABLE [BOOLEAN, STRING]
		do
			create Result.make (20)
			create l_path.make (10)
			create l_visited.make (10)

			if attached a_machine.initial_state as init then
				enumerate_paths_recursive (a_machine, init, l_path, l_visited, Result, 10)
			end
		end

	enumerate_paths_recursive (a_machine: SV_STATE_MACHINE; a_state: STRING;
			a_path: ARRAYED_LIST [STRING]; a_visited: HASH_TABLE [BOOLEAN, STRING];
			a_results: ARRAYED_LIST [ARRAYED_LIST [STRING]]; a_depth: INTEGER)
			-- Recursively enumerate paths.
		local
			l_events: ARRAYED_LIST [STRING]
			l_path_copy: ARRAYED_LIST [STRING]
		do
			if a_depth <= 0 then
				-- Max depth reached, save current path
				a_results.extend (a_path.twin)
			elseif a_visited.has (a_state) then
				-- Cycle detected, save current path
				a_results.extend (a_path.twin)
			else
				a_visited.put (True, a_state)
				l_events := a_machine.events_from (a_state)

				if l_events.is_empty then
					-- Terminal state, save path
					a_results.extend (a_path.twin)
				else
					across l_events as ev loop
						l_path_copy := a_path.twin
						l_path_copy.extend (ev.item)

						-- Find target state
						across a_machine.transitions as t loop
							if t.item.from_state.same_string (a_state) and
							   t.item.event.same_string (ev.item) then
								enumerate_paths_recursive (a_machine, t.item.to_state,
									l_path_copy, a_visited.twin, a_results, a_depth - 1)
							end
						end
					end
				end

				a_visited.remove (a_state)
			end
		end

	execute_path (a_machine: SV_STATE_MACHINE; a_events: ARRAYED_LIST [STRING]): BOOLEAN
			-- Execute path of events, return True if all succeed.
		do
			Result := True
			across a_events as ev loop
				if Result then
					Result := a_machine.trigger (ev.item)
				end
			end
		end

	path_to_string (a_path: ARRAYED_LIST [STRING]): STRING
			-- Convert event path to readable string.
		do
			create Result.make (50)
			across a_path as ev loop
				if not Result.is_empty then
					Result.append (" -> ")
				end
				Result.append (ev.item)
			end
			if Result.is_empty then
				Result := "(empty path)"
			end
		end

feature {NONE} -- Implementation

	execute_step (a_step: SV_TEST_STEP)
			-- Execute a single test step.
		require
			step_attached: a_step /= Void
		do
			debug_log ("Executing step " + current_step.out + ": " + a_step.action)
			if a_step.action.same_string ("click") then
				simulate_click_by_name (a_step.target)
			elseif a_step.action.same_string ("assert_text") then
				last_result := assert_text_by_name (a_step.target, a_step.value)
			elseif a_step.action.same_string ("assert_visible") then
				if attached widget (a_step.target) as w then
					last_result := assert_visible (w)
				end
			elseif a_step.action.same_string ("assert_enabled") then
				if attached widget (a_step.target) as w then
					last_result := assert_enabled (w)
				end
			elseif a_step.action.same_string ("wait") then
				wait (a_step.wait_ms)
			else
				debug_log ("Unknown action: " + a_step.action)
			end
		end

	last_result: BOOLEAN
			-- Result of last assertion (for discarding return values).

	wait (a_milliseconds: INTEGER)
			-- Wait for specified time.
		local
			l_env: EXECUTION_ENVIRONMENT
		do
			create l_env
			l_env.sleep (a_milliseconds * 1_000_000) -- nanoseconds
		end

invariant
	recorded_events_exists: recorded_events /= Void
	registered_widgets_exists: registered_widgets /= Void
	assertions_exists: assertions /= Void

end
