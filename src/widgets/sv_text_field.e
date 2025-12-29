note
	description: "Text input field - wraps EV_TEXT_FIELD"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TEXT_FIELD

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
			-- Create empty text field.
		do
			create ev_text_field
			is_showing_placeholder := False
			setup_placeholder_handlers
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create text field with initial text.
		require
			text_not_void: a_text /= Void
		do
			create ev_text_field
			ev_text_field.set_text (a_text.to_string_32)
			is_showing_placeholder := False
			setup_placeholder_handlers
			apply_theme
			subscribe_to_theme
		ensure
			text_set: text.same_string_general (a_text)
		end

	setup_placeholder_handlers
			-- Set up focus/blur handlers for placeholder.
		do
			ev_text_field.focus_in_actions.extend (agent on_focus_in)
			ev_text_field.focus_out_actions.extend (agent on_focus_out)
		end

feature -- Access

	ev_text_field: EV_TEXT_FIELD
			-- Underlying EiffelVision-2 text field.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_text_field
		end

	text: STRING_32
			-- Current text content (excluding placeholder).
		do
			if is_showing_placeholder then
				Result := ""
			else
				Result := ev_text_field.text
			end
		end

feature -- Text Operations

	set_text (a_text: READABLE_STRING_GENERAL)
			-- Set field text (procedure).
		require
			text_not_void: a_text /= Void
		do
			ev_text_field.set_text (a_text.to_string_32)
			notify_change
		ensure
			text_set: text.same_string_general (a_text)
		end

	content (a_text: READABLE_STRING_GENERAL): like Current
			-- Set field text (fluent).
		require
			text_not_void: a_text /= Void
		do
			set_text (a_text)
			Result := Current
		ensure
			text_set: text.same_string_general (a_text)
			result_is_current: Result = Current
		end

	clear
			-- Clear all text.
		do
			ev_text_field.remove_text
			notify_change
		ensure
			empty: text.is_empty
		end

	select_all
			-- Select all text.
		do
			ev_text_field.select_all
		end

feature -- Placeholder

	set_placeholder (a_text: READABLE_STRING_GENERAL): like Current
			-- Set placeholder/hint text that shows when field is empty.
		require
			text_not_void: a_text /= Void
		do
			placeholder_text := a_text.to_string_32
			-- Show placeholder if currently empty
			if ev_text_field.text.is_empty then
				show_placeholder
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	placeholder (a_text: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_placeholder.
		require
			text_not_void: a_text /= Void
		do
			Result := set_placeholder (a_text)
		ensure
			result_is_current: Result = Current
		end

	has_placeholder: BOOLEAN
			-- Is there placeholder text defined?
		do
			Result := attached placeholder_text as pt and then not pt.is_empty
		end

feature -- Validation State

	is_valid: BOOLEAN
			-- Does current text pass validation?
		do
			if attached validator as v then
				Result := v.item ([text])
			else
				Result := True -- No validator = always valid
			end
		end

	set_validator (a_validator: FUNCTION [STRING_32, BOOLEAN]): like Current
			-- Set validation function.
		require
			validator_attached: a_validator /= Void
		do
			validator := a_validator
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	validate_not_empty: like Current
			-- Require non-empty text.
		do
			Result := set_validator (agent (s: STRING_32): BOOLEAN do Result := not s.is_empty end)
		ensure
			result_is_current: Result = Current
		end

	validate_min_length (a_min: INTEGER): like Current
			-- Require minimum length.
		require
			positive: a_min > 0
		do
			Result := set_validator (agent (s: STRING_32; min: INTEGER): BOOLEAN do Result := s.count >= min end (?, a_min))
		ensure
			result_is_current: Result = Current
		end

	validate_max_length (a_max: INTEGER): like Current
			-- Require maximum length.
		require
			positive: a_max > 0
		do
			Result := set_validator (agent (s: STRING_32; max: INTEGER): BOOLEAN do Result := s.count <= max end (?, a_max))
		ensure
			result_is_current: Result = Current
		end

feature -- Password Mode

	set_password_mode: like Current
			-- Hide text input (for passwords).
		do
			-- EV_TEXT_FIELD doesn't have password mode built-in
			-- Would need EV_PASSWORD_FIELD or custom masking
			is_password := True
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	is_password: BOOLEAN
			-- Is this a password field?

feature -- Read-Only

	set_read_only: like Current
			-- Make field read-only.
		do
			ev_text_field.disable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_editable: like Current
			-- Make field editable.
		do
			ev_text_field.enable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	read_only: like Current
			-- Fluent alias for set_read_only.
		do
			Result := set_read_only
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_change (a_action: PROCEDURE)
			-- Set action for text changes.
		require
			action_attached: a_action /= Void
		do
			ev_text_field.change_actions.extend (a_action)
		end

	on_return (a_action: PROCEDURE)
			-- Set action for Enter/Return key.
		require
			action_attached: a_action /= Void
		do
			ev_text_field.return_actions.extend (a_action)
		end

	changed (a_action: PROCEDURE): like Current
			-- Fluent version of on_change.
		require
			action_attached: a_action /= Void
		do
			on_change (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	on_submit (a_action: PROCEDURE): like Current
			-- Fluent version of on_return (modern name).
		require
			action_attached: a_action /= Void
		do
			on_return (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and font to text field.
		do
			ev_text_field.set_background_color (tokens.surface.to_ev_color)
			if is_showing_placeholder then
				ev_text_field.set_foreground_color (tokens.text_hint.to_ev_color)
			else
				ev_text_field.set_foreground_color (tokens.text_primary.to_ev_color)
			end
			ev_text_field.set_font (theme.scaled_font)
		end

feature {NONE} -- Implementation

	placeholder_text: detachable STRING_32
			-- Placeholder hint text.

	is_showing_placeholder: BOOLEAN
			-- Is placeholder currently being displayed?

	validator: detachable FUNCTION [STRING_32, BOOLEAN]
			-- Validation function.

	show_placeholder
			-- Display placeholder text in subdued color.
		do
			if attached placeholder_text as pt and then not pt.is_empty then
				ev_text_field.set_text (pt)
				ev_text_field.set_foreground_color (tokens.text_hint.to_ev_color)
				is_showing_placeholder := True
			end
		end

	hide_placeholder
			-- Remove placeholder text and restore normal color.
		do
			if is_showing_placeholder then
				ev_text_field.set_text ("")
				ev_text_field.set_foreground_color (tokens.text_primary.to_ev_color)
				is_showing_placeholder := False
			end
		end

	on_focus_in
			-- Handle focus entering field - hide placeholder.
		do
			if is_showing_placeholder then
				hide_placeholder
			end
		end

	on_focus_out
			-- Handle focus leaving field - show placeholder if empty.
		do
			if ev_text_field.text.is_empty and has_placeholder then
				show_placeholder
			end
		end

	notify_change
			-- Notify harness of text change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("text", "", text.to_string_8))
			end
		end

invariant
	ev_text_field_exists: ev_text_field /= Void

end
