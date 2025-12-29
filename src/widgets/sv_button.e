note
	description: "Button widget - wraps EV_BUTTON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_BUTTON

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
			-- Create button with no label.
		do
			create ev_button
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create button with label.
		require
			text_not_empty: not a_text.is_empty
		do
			create ev_button.make_with_text (a_text.to_string_32)
			apply_theme
			subscribe_to_theme
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Access

	ev_button: EV_BUTTON
			-- Underlying EiffelVision-2 button.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_button
		end

	text: STRING_32
			-- Button label text.
		do
			Result := ev_button.text
		end

feature -- Fluent Configuration

	set_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set button label.
		require
			text_not_void: a_text /= Void
		do
			ev_button.set_text (a_text.to_string_32)
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

	on_click (a_action: PROCEDURE)
			-- Set action to execute when button is clicked.
		require
			action_attached: a_action /= Void
		do
			ev_button.select_actions.extend (a_action)
		end

	clicked (a_action: PROCEDURE): like Current
			-- Fluent version of on_click.
		require
			action_attached: a_action /= Void
		do
			on_click (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Tooltip

	set_tooltip (a_text: READABLE_STRING_GENERAL): like Current
			-- Set button tooltip.
		require
			text_not_void: a_text /= Void
		do
			ev_button.set_tooltip (a_text.to_string_32)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	tooltip (a_text: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_tooltip.
		require
			text_not_void: a_text /= Void
		do
			Result := set_tooltip (a_text)
		ensure
			result_is_current: Result = Current
		end

feature -- Default Button

	set_default: like Current
			-- Make this button the default (responds to Enter key).
		do
			-- Note: Default button behavior requires parent window context.
			-- This is a placeholder for future implementation.
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled font to button.
		do
			ev_button.set_foreground_color (tokens.on_primary.to_ev_color)
			ev_button.set_background_color (tokens.primary.to_ev_color)
			ev_button.set_font (theme.scaled_font)
		end

invariant
	ev_button_exists: ev_button /= Void

end
