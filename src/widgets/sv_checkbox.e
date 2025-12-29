note
	description: "Checkbox widget - wraps EV_CHECK_BUTTON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_CHECKBOX

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_text

feature {NONE} -- Initialization

	make
			-- Create checkbox with no label.
		do
			create ev_check_button
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create checkbox with label.
		require
			text_not_void: a_text /= Void
		do
			create ev_check_button.make_with_text (a_text.to_string_32)
			apply_theme
			subscribe_to_theme
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Access

	ev_check_button: EV_CHECK_BUTTON
			-- Underlying EiffelVision-2 check button.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_check_button
		end

	text: STRING_32
			-- Checkbox label text.
		do
			Result := ev_check_button.text
		end

feature -- State

	is_checked: BOOLEAN
			-- Is checkbox checked?
		do
			Result := ev_check_button.is_selected
		end

	check_now
			-- Check the checkbox (procedure).
		do
			ev_check_button.enable_select
			notify_state_change
		ensure
			checked: is_checked
		end

	uncheck_now
			-- Uncheck the checkbox (procedure).
		do
			ev_check_button.disable_select
			notify_state_change
		ensure
			unchecked: not is_checked
		end

	toggle
			-- Toggle checkbox state.
		do
			if is_checked then
				uncheck_now
			else
				check_now
			end
		end

	checked: like Current
			-- Set checkbox to checked (fluent).
		do
			check_now
			Result := Current
		ensure
			is_checked: is_checked
			result_is_current: Result = Current
		end

	unchecked: like Current
			-- Set checkbox to unchecked (fluent).
		do
			uncheck_now
			Result := Current
		ensure
			not_checked: not is_checked
			result_is_current: Result = Current
		end

	set_checked (a_checked: BOOLEAN): like Current
			-- Set checkbox state (fluent).
		do
			if a_checked then
				check_now
			else
				uncheck_now
			end
			Result := Current
		ensure
			state_set: is_checked = a_checked
			result_is_current: Result = Current
		end

feature -- Label

	set_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set checkbox label.
		require
			text_not_void: a_text /= Void
		do
			ev_check_button.set_text (a_text.to_string_32)
			Result := Current
		ensure
			text_set: text.same_string_general (a_text)
			result_is_current: Result = Current
		end

	label (a_text: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_text.
		require
			text_not_void: a_text /= Void
		do
			Result := set_text (a_text)
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_toggle (a_action: PROCEDURE)
			-- Set action for state change.
		require
			action_attached: a_action /= Void
		do
			ev_check_button.select_actions.extend (a_action)
		end

	toggled (a_action: PROCEDURE): like Current
			-- Fluent version of on_toggle.
		require
			action_attached: a_action /= Void
		do
			on_toggle (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	on_check (a_action: PROCEDURE)
			-- Set action for when checkbox becomes checked.
		require
			action_attached: a_action /= Void
		do
			ev_check_button.select_actions.extend (agent check_and_call (a_action, True))
		end

	on_uncheck (a_action: PROCEDURE)
			-- Set action for when checkbox becomes unchecked.
		require
			action_attached: a_action /= Void
		do
			ev_check_button.select_actions.extend (agent check_and_call (a_action, False))
		end

feature {NONE} -- Implementation

	check_and_call (a_action: PROCEDURE; a_when_checked: BOOLEAN)
			-- Call action only when checkbox matches expected state.
		do
			if is_checked = a_when_checked then
				a_action.call (Void)
			end
		end

	notify_state_change
			-- Notify harness of state change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("checked",
					(if is_checked then "false" else "true" end),
					(if is_checked then "true" else "false" end)))
			end
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled font to checkbox.
		do
			ev_check_button.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_check_button.set_background_color (tokens.surface.to_ev_color)
			ev_check_button.set_font (theme.scaled_font)
		end

invariant
	ev_check_button_exists: ev_check_button /= Void

end
