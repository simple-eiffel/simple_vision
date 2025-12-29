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
