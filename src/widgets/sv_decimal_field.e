note
	description: "Decimal input field for precise numeric entry - integrates with simple_decimal"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_DECIMAL_FIELD

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_value

feature {NONE} -- Initialization

	make
			-- Create empty decimal field.
		do
			create ev_text_field
			create internal_value.make_zero
			decimal_places := 2
			allow_negative := True
			is_showing_placeholder := False
			setup_handlers
			apply_theme
			subscribe_to_theme
		end

	make_with_value (a_value: SIMPLE_DECIMAL)
			-- Create field with initial value.
		require
			value_attached: a_value /= Void
		do
			make
			set_value (a_value)
		ensure
			value_set: value.is_equal (a_value)
		end

	setup_handlers
			-- Set up event handlers.
		do
			ev_text_field.focus_in_actions.extend (agent on_focus_in)
			ev_text_field.focus_out_actions.extend (agent on_focus_out)
			ev_text_field.change_actions.extend (agent on_text_change)
		end

feature -- Access

	ev_text_field: EV_TEXT_FIELD
			-- Underlying EiffelVision-2 text field.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_text_field
		end

	value: SIMPLE_DECIMAL
			-- Current decimal value.
		do
			Result := internal_value.twin
		end

	text: STRING_32
			-- Current text (formatted value or input).
		do
			if is_showing_placeholder then
				Result := ""
			else
				Result := ev_text_field.text
			end
		end

	decimal_places: INTEGER
			-- Number of decimal places for display.

	allow_negative: BOOLEAN
			-- Are negative values allowed?

feature -- Value Operations

	set_value (a_value: SIMPLE_DECIMAL)
			-- Set the decimal value.
		require
			value_attached: a_value /= Void
		do
			internal_value := a_value
			update_display
			notify_change
		ensure
			value_set: value.is_equal (a_value)
		end

	clear
			-- Clear the field (set to zero).
		do
			create internal_value.make_zero
			update_display
			notify_change
		ensure
			is_zero: value.is_zero
		end

feature -- Configuration

	set_decimal_places (a_places: INTEGER): like Current
			-- Set number of decimal places.
		require
			non_negative: a_places >= 0
		do
			decimal_places := a_places
			update_display
			Result := Current
		ensure
			result_is_current: Result = Current
			places_set: decimal_places = a_places
		end

	cents: like Current
			-- Configure for currency (2 decimal places).
		do
			Result := set_decimal_places (2)
		ensure
			result_is_current: Result = Current
		end

	whole_numbers: like Current
			-- Configure for whole numbers only.
		do
			Result := set_decimal_places (0)
		ensure
			result_is_current: Result = Current
		end

	set_allow_negative (a_allow: BOOLEAN): like Current
			-- Set whether negative values are allowed.
		do
			allow_negative := a_allow
			Result := Current
		ensure
			result_is_current: Result = Current
			allow_set: allow_negative = a_allow
		end

	positive_only: like Current
			-- Only allow positive values.
		do
			Result := set_allow_negative (False)
		ensure
			result_is_current: Result = Current
		end

feature -- Placeholder

	set_placeholder (a_text: READABLE_STRING_GENERAL): like Current
			-- Set placeholder text shown when empty.
		require
			text_not_void: a_text /= Void
		do
			placeholder_text := a_text.to_string_32
			if internal_value.is_zero and not is_focused then
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

feature -- Events

	on_change (a_action: PROCEDURE [SIMPLE_DECIMAL])
			-- Set action for value changes.
		require
			action_attached: a_action /= Void
		do
			change_action := a_action
		end

	changed (a_action: PROCEDURE [SIMPLE_DECIMAL]): like Current
			-- Fluent version of on_change.
		require
			action_attached: a_action /= Void
		do
			on_change (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Validation

	is_valid: BOOLEAN
			-- Is current input valid?
		do
			Result := is_valid_input (ev_text_field.text)
		end

	min_value: detachable SIMPLE_DECIMAL
			-- Minimum allowed value (if set).

	max_value: detachable SIMPLE_DECIMAL
			-- Maximum allowed value (if set).

	set_min (a_min: SIMPLE_DECIMAL): like Current
			-- Set minimum allowed value.
		require
			min_attached: a_min /= Void
		do
			min_value := a_min
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_max (a_max: SIMPLE_DECIMAL): like Current
			-- Set maximum allowed value.
		require
			max_attached: a_max /= Void
		do
			max_value := a_max
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_range (a_min, a_max: SIMPLE_DECIMAL): like Current
			-- Set allowed range.
		require
			min_attached: a_min /= Void
			max_attached: a_max /= Void
			valid_range: a_min <= a_max
		do
			min_value := a_min
			max_value := a_max
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and font to field.
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

	internal_value: SIMPLE_DECIMAL
			-- Internal decimal value.

	placeholder_text: detachable STRING_32
			-- Placeholder text.

	is_showing_placeholder: BOOLEAN
			-- Is placeholder currently shown?

	is_focused: BOOLEAN
			-- Is field currently focused?

	change_action: detachable PROCEDURE [SIMPLE_DECIMAL]
			-- Action to call on value change.

	update_display
			-- Update text field display from internal value.
		local
			l_text: STRING
		do
			if is_showing_placeholder then
				-- Leave placeholder visible
			else
				l_text := internal_value.to_string
				ev_text_field.set_text (l_text)
			end
		end

	on_focus_in
			-- Handle focus entering field.
		do
			is_focused := True
			if is_showing_placeholder then
				hide_placeholder
			end
		end

	on_focus_out
			-- Handle focus leaving field.
		local
			l_text: STRING
		do
			is_focused := False
			l_text := ev_text_field.text.to_string_8
			if l_text.is_empty then
				create internal_value.make_zero
				if attached placeholder_text as pt and then not pt.is_empty then
					show_placeholder
				else
					update_display
				end
			elseif is_valid_input (ev_text_field.text) then
				create internal_value.make (l_text)
				-- Apply constraints
				if not allow_negative and internal_value < (create {SIMPLE_DECIMAL}.make_zero) then
					create internal_value.make_zero
				end
				if attached min_value as mn and then internal_value < mn then
					internal_value := mn
				end
				if attached max_value as mx and then internal_value > mx then
					internal_value := mx
				end
				update_display
			else
				-- Invalid input - revert to previous value
				update_display
			end
			notify_change
		end

	on_text_change
			-- Handle text changes during editing.
		do
			-- Could add live validation feedback here
		end

	show_placeholder
			-- Show placeholder text.
		do
			if attached placeholder_text as pt and then not pt.is_empty then
				ev_text_field.set_text (pt)
				ev_text_field.set_foreground_color (tokens.text_hint.to_ev_color)
				is_showing_placeholder := True
			end
		end

	hide_placeholder
			-- Hide placeholder and show empty field.
		do
			if is_showing_placeholder then
				ev_text_field.set_text ("")
				ev_text_field.set_foreground_color (tokens.text_primary.to_ev_color)
				is_showing_placeholder := False
			end
		end

	is_valid_input (a_text: READABLE_STRING_GENERAL): BOOLEAN
			-- Is the input text a valid decimal?
		local
			l_str: STRING
			l_char: CHARACTER
			i: INTEGER
			l_has_dot: BOOLEAN
			l_has_digit: BOOLEAN
		do
			l_str := a_text.to_string_8
			if l_str.is_empty then
				Result := True -- Empty is valid (becomes zero)
			else
				Result := True
				from i := 1 until i > l_str.count or not Result loop
					l_char := l_str.item (i)
					if l_char.is_digit then
						l_has_digit := True
					elseif l_char = '.' then
						if l_has_dot then
							Result := False -- Multiple dots
						else
							l_has_dot := True
						end
					elseif l_char = '-' then
						if i /= 1 or not allow_negative then
							Result := False -- Minus only at start, and if allowed
						end
					elseif l_char = ',' then
						-- Allow comma as thousand separator
					else
						Result := False -- Invalid character
					end
					i := i + 1
				end
				Result := Result and l_has_digit
			end
		end

	notify_change
			-- Notify of value change.
		do
			if attached change_action as act then
				act.call ([value])
			end
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("value", "", value.to_string))
			end
		end

invariant
	ev_text_field_exists: ev_text_field /= Void
	internal_value_exists: internal_value /= Void
	non_negative_places: decimal_places >= 0

end
