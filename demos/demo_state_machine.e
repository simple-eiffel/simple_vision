note
	description: "Demo: State machine for UI state management (Phase 6.75+)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_STATE_MACHINE

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create demo application.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor
			create l_app.make
			l_win := build_ui
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature {NONE} -- UI Building

	build_ui: SV_WINDOW
			-- Build the main UI.
		local
			l_main: SV_COLUMN
		do
			Result := window ("State Machine Demo - Phase 6.75+").size (500, 500)

			-- Create state machine first (no widget references in it)
			create_media_player_machine

			-- Create widgets
			create_widgets

			-- Build UI layout
			l_main := column.spacing (15).padding (20)
				.add (text ("Media Player State Machine").bold.font_size (18))
				.add (text ("Demonstrates SV_STATE_MACHINE with entry/exit actions"))
				.add (divider)
				.add (create_state_display)
				.add (divider)
				.add (create_control_buttons)
				.add (divider)
				.add (create_history_section)
				.add (divider)
				.add (row.spacing (10)
					.add (button ("Toggle Dark Mode").clicked (agent toggle_theme))
					.add (spacer)
					.add (button ("Reset").clicked (agent on_reset))
				)

			Result.extend (l_main)

			-- Start the machine and update display
			media_player.start
			update_display
		end

	create_widgets
			-- Create all widget attributes.
		do
			state_label := text ("Current State: (not started)").bold.font_size (16).id ("state_label")
			indicator_label := text ("").id ("indicator_label")
			event_label := text ("Last Event: none").id ("event_label")
			history_label := text ("Transition history will appear here...").id ("history_label")
			play_btn := button ("Play").id ("btn_play")
			pause_btn := button ("Pause").id ("btn_pause")
			stop_btn := button ("Stop").id ("btn_stop")
			eject_btn := button ("Eject").id ("btn_eject")
		end

	create_state_display: SV_WIDGET
			-- Create state display section.
		do
			Result := card.titled ("Current State")
				.content (
					column.spacing (10).padding (10)
						.add (state_label)
						.add (indicator_label)
						.add (event_label)
				)
		end

	create_control_buttons: SV_WIDGET
			-- Create media player control buttons.
		do
			play_btn.on_click (agent on_play)
			pause_btn.on_click (agent on_pause)
			stop_btn.on_click (agent on_stop)
			eject_btn.on_click (agent on_eject)

			Result := card.titled ("Controls")
				.content (
					row.spacing (15).padding (10)
						.add (play_btn)
						.add (pause_btn)
						.add (stop_btn)
						.add (eject_btn)
				)
		end

	create_history_section: SV_WIDGET
			-- Create transition history display.
		do
			Result := card.titled ("Transition History")
				.content (
					column.padding (10)
						.add (history_label)
				)
		end

feature {NONE} -- State Machine

	media_player: SV_STATE_MACHINE
			-- The media player state machine.

	create_media_player_machine
			-- Create and configure the state machine.
		do
			create media_player.make ("media_player")

			-- Define states (no entry/exit actions that reference widgets)
			media_player.state ("idle").described_as ("Player is idle, no media loaded").do_nothing
			media_player.state ("loading").described_as ("Loading media...").do_nothing
			media_player.state ("playing").described_as ("Media is playing").do_nothing
			media_player.state ("paused").described_as ("Playback paused").do_nothing
			media_player.state ("stopped").described_as ("Playback stopped").do_nothing

			-- Define transitions
			media_player.on ("load").from_state ("idle").to ("loading").apply.do_nothing
			media_player.on ("loaded").from_state ("loading").to ("stopped").apply.do_nothing
			media_player.on ("play").from_state ("stopped").to ("playing").apply.do_nothing
			media_player.on ("play").from_state ("paused").to ("playing").apply.do_nothing
			media_player.on ("pause").from_state ("playing").to ("paused").apply.do_nothing
			media_player.on ("stop").from_state ("playing").to ("stopped").apply.do_nothing
			media_player.on ("stop").from_state ("paused").to ("stopped").apply.do_nothing
			media_player.on ("eject").from_state ("stopped").to ("idle").apply.do_nothing
			media_player.on ("eject").from_state ("paused").to ("idle").apply.do_nothing

			-- Set initial state
			media_player.set_initial ("idle").do_nothing
		end

feature {NONE} -- Event Handlers

	on_play
			-- Handle play button.
		do
			if media_player.is_in ("idle") then
				-- First need to load
				media_player.trigger ("load").do_nothing
				-- Simulate auto-load completion
				media_player.trigger ("loaded").do_nothing
			end
			media_player.trigger ("play").do_nothing
			update_display
		end

	on_pause
			-- Handle pause button.
		do
			media_player.trigger ("pause").do_nothing
			update_display
		end

	on_stop
			-- Handle stop button.
		do
			media_player.trigger ("stop").do_nothing
			update_display
		end

	on_eject
			-- Handle eject button.
		do
			media_player.trigger ("eject").do_nothing
			update_display
		end

	on_reset
			-- Reset state machine.
		do
			media_player.reset
			update_display
		end

	toggle_theme
			-- Toggle dark mode.
		do
			theme.toggle_dark_mode
		end

feature {NONE} -- Display Update

	update_display
			-- Update all display elements.
		local
			l_history: STRING
			l_indicator: STRING
		do
			-- Update state label
			if attached media_player.current_state as cs then
				state_label.update_text ("Current State: " + cs.name.as_upper)
			else
				state_label.update_text ("Current State: (not started)")
			end

			-- Update indicator based on state
			l_indicator := state_indicator (media_player.current_state_name)
			indicator_label.update_text (l_indicator)

			-- Update event label
			if not media_player.last_event.is_empty then
				event_label.update_text ("Last Event: " + media_player.last_event)
			else
				event_label.update_text ("Last Event: none")
			end

			-- Update history
			create l_history.make (500)
			if media_player.transition_history.is_empty then
				l_history.append ("(no transitions yet)")
			else
				across media_player.transition_history as h loop
					l_history.append (h.from_state + " --[" + h.event + "]--> " + h.to_state + "%N")
				end
			end
			history_label.update_text (l_history)
		end

	state_indicator (a_state: STRING): STRING
			-- Get visual indicator for state.
		do
			if a_state.same_string ("idle") then
				Result := "[ ] No media loaded - click Play to load"
			elseif a_state.same_string ("loading") then
				Result := "[...] Loading media..."
			elseif a_state.same_string ("playing") then
				Result := "[>>>] Now playing..."
			elseif a_state.same_string ("paused") then
				Result := "[ || ] Paused"
			elseif a_state.same_string ("stopped") then
				Result := "[ @ ] Stopped - ready to play"
			else
				Result := "[?] Unknown state"
			end
		end

feature {NONE} -- Widget References

	state_label: SV_TEXT
	indicator_label: SV_TEXT
	event_label: SV_TEXT
	history_label: SV_TEXT
	play_btn: SV_BUTTON
	pause_btn: SV_BUTTON
	stop_btn: SV_BUTTON
	eject_btn: SV_BUTTON

end
