note
	description: "[
		Masked text input field with regex-based validation.

		Integrates with simple_regex for pattern validation and provides
		visual feedback for validation state (valid/invalid colors).

		Pre-built masks available:
		- phone_us: (123) 456-7890 format
		- phone_intl: International phone format
		- ssn: 123-45-6789 format
		- date_iso: YYYY-MM-DD format
		- date_us: MM/DD/YYYY format
		- email: Standard email format
		- zip_us: 12345 or 12345-6789 format
		- credit_card: 16 digits with optional separators
		- currency: $1,234.56 format

		Usage:
			create field.make
			field.mask_phone_us.placeholder ("Enter phone number")

		Or with custom pattern:
			field.set_mask ("^[A-Z]{3}[0-9]{4}$").placeholder ("Enter code")
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MASKED_FIELD

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_mask

feature {NONE} -- Initialization

	make
			-- Create empty masked field.
		do
			create ev_text_field
			create regex.make
			create patterns.make
			is_valid := True
			is_showing_placeholder := False
			validate_on_change := True
			setup_handlers
			apply_theme
			subscribe_to_theme
		end

	make_with_mask (a_pattern: READABLE_STRING_GENERAL)
			-- Create field with regex mask pattern.
		require
			pattern_attached: a_pattern /= Void
		do
			make
			set_mask (a_pattern).do_nothing
		end

	setup_handlers
			-- Set up event handlers.
		do
			ev_text_field.focus_in_actions.extend (agent on_focus_in)
			ev_text_field.focus_out_actions.extend (agent on_focus_out)
			ev_text_field.change_actions.extend (agent on_text_change)
			ev_text_field.key_press_string_actions.extend (agent on_key_press_string)
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

	mask_pattern: detachable STRING_32
			-- Current regex mask pattern.

	is_valid: BOOLEAN
			-- Does current text pass validation?

	validation_message: detachable STRING_32
			-- Custom message for validation failure.

feature -- Text Operations

	set_text (a_text: READABLE_STRING_GENERAL)
			-- Set field text.
		require
			text_attached: a_text /= Void
		do
			ev_text_field.set_text (a_text.to_string_32)
			validate_input
			notify_change
		end

	content (a_text: READABLE_STRING_GENERAL): like Current
			-- Set field text (fluent).
		require
			text_attached: a_text /= Void
		do
			set_text (a_text)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear
			-- Clear text and reset validation.
		do
			ev_text_field.remove_text
			is_valid := True
			apply_validation_colors
			notify_change
		end

feature -- Mask Configuration

	set_mask (a_pattern: READABLE_STRING_GENERAL): like Current
			-- Set custom regex mask pattern.
		require
			pattern_attached: a_pattern /= Void
		do
			mask_pattern := a_pattern.to_string_32
			regex.compile (a_pattern)
			if not regex.is_compiled then
				-- Pattern error - store for debugging
				validation_message := regex.last_error
			end
			validate_input
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	mask (a_pattern: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_mask.
		require
			pattern_attached: a_pattern /= Void
		do
			Result := set_mask (a_pattern)
		ensure
			result_is_current: Result = Current
		end

feature -- Pre-Built Masks

	mask_phone_us: like Current
			-- Mask for US phone number: (123) 456-7890.
		do
			Result := set_mask (patterns.phone_us_pattern)
			input_mask := "(###) ###-####"
			validation_message := "Enter a valid US phone number"
		ensure
			result_is_current: Result = Current
		end

	mask_phone_international: like Current
			-- Mask for international phone: +1-234-567-8900, etc.
			-- Note: No input mask (variable format).
		do
			Result := set_mask (patterns.phone_international_pattern)
			validation_message := "Enter a valid international phone number"
		ensure
			result_is_current: Result = Current
		end

	mask_ssn: like Current
			-- Mask for Social Security Number: 123-45-6789.
		do
			Result := set_mask (patterns.ssn_pattern)
			input_mask := "###-##-####"
			validation_message := "Enter SSN as 123-45-6789"
		ensure
			result_is_current: Result = Current
		end

	mask_date_iso: like Current
			-- Mask for ISO date: YYYY-MM-DD.
		do
			Result := set_mask (patterns.date_iso_pattern)
			input_mask := "####-##-##"
			validation_message := "Enter date as YYYY-MM-DD"
		ensure
			result_is_current: Result = Current
		end

	mask_date_us: like Current
			-- Mask for US date: MM/DD/YYYY.
		do
			Result := set_mask (patterns.date_us_pattern)
			input_mask := "##/##/####"
			validation_message := "Enter date as MM/DD/YYYY"
		ensure
			result_is_current: Result = Current
		end

	mask_date_eu: like Current
			-- Mask for EU date: DD/MM/YYYY.
		do
			Result := set_mask (patterns.date_eu_pattern)
			input_mask := "##/##/####"
			validation_message := "Enter date as DD/MM/YYYY"
		ensure
			result_is_current: Result = Current
		end

	mask_email: like Current
			-- Mask for email address.
			-- Note: No input mask (variable format).
		do
			Result := set_mask (patterns.email_pattern)
			validation_message := "Enter a valid email address"
		ensure
			result_is_current: Result = Current
		end

	mask_zip_us: like Current
			-- Mask for US ZIP code: 12345.
		do
			Result := set_mask (patterns.zip_code_us_pattern)
			input_mask := "#####"
			validation_message := "Enter ZIP as 12345"
		ensure
			result_is_current: Result = Current
		end

	mask_credit_card: like Current
			-- Mask for credit card number: 1234 5678 9012 3456.
		do
			Result := set_mask (patterns.credit_card_pattern)
			input_mask := "#### #### #### ####"
			validation_message := "Enter a valid credit card number"
		ensure
			result_is_current: Result = Current
		end

	mask_currency: like Current
			-- Mask for currency amount: $1,234.56.
		do
			Result := set_mask (patterns.currency_pattern)
			validation_message := "Enter amount as $1,234.56"
		ensure
			result_is_current: Result = Current
		end

	mask_integer: like Current
			-- Mask for integer numbers.
		do
			Result := set_mask (patterns.integer_pattern)
			validation_message := "Enter a whole number"
		ensure
			result_is_current: Result = Current
		end

	mask_decimal: like Current
			-- Mask for decimal numbers.
		do
			Result := set_mask (patterns.decimal_pattern)
			validation_message := "Enter a decimal number"
		ensure
			result_is_current: Result = Current
		end

	mask_alphanumeric: like Current
			-- Mask for alphanumeric text only.
		do
			Result := set_mask (patterns.alphanumeric_pattern)
			validation_message := "Enter letters and numbers only"
		ensure
			result_is_current: Result = Current
		end

	mask_alphabetic: like Current
			-- Mask for alphabetic text only.
		do
			Result := set_mask (patterns.alphabetic_pattern)
			validation_message := "Enter letters only"
		ensure
			result_is_current: Result = Current
		end

	mask_ipv4: like Current
			-- Mask for IPv4 address.
		do
			Result := set_mask (patterns.ipv4_pattern)
			validation_message := "Enter a valid IPv4 address"
		ensure
			result_is_current: Result = Current
		end

	mask_url: like Current
			-- Mask for URL.
		do
			Result := set_mask (patterns.url_pattern)
			validation_message := "Enter a valid URL"
		ensure
			result_is_current: Result = Current
		end

	mask_uuid: like Current
			-- Mask for UUID/GUID.
		do
			Result := set_mask (patterns.uuid_pattern)
			validation_message := "Enter a valid UUID"
		ensure
			result_is_current: Result = Current
		end

	mask_hex_color: like Current
			-- Mask for hex color code.
		do
			Result := set_mask (patterns.hex_color_pattern)
			validation_message := "Enter color as #FFF or #FFFFFF"
		ensure
			result_is_current: Result = Current
		end

	mask_time_24h: like Current
			-- Mask for 24-hour time: HH:MM or HH:MM:SS.
		do
			Result := set_mask (patterns.time_24h_pattern)
			validation_message := "Enter time as HH:MM or HH:MM:SS"
		ensure
			result_is_current: Result = Current
		end

	mask_time_12h: like Current
			-- Mask for 12-hour time: HH:MM AM/PM.
		do
			Result := set_mask (patterns.time_12h_pattern)
			validation_message := "Enter time as HH:MM AM/PM"
		ensure
			result_is_current: Result = Current
		end

feature -- Placeholder

	set_placeholder (a_text: READABLE_STRING_GENERAL): like Current
			-- Set placeholder text shown when empty.
		require
			text_attached: a_text /= Void
		do
			placeholder_text := a_text.to_string_32
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
			text_attached: a_text /= Void
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

feature -- Validation Options

	set_validation_message (a_message: READABLE_STRING_GENERAL): like Current
			-- Set custom validation error message.
		require
			message_attached: a_message /= Void
		do
			validation_message := a_message.to_string_32
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_validate_on_change (a_value: BOOLEAN): like Current
			-- Set whether to validate on every keystroke.
		do
			validate_on_change := a_value
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	validate_on_blur: like Current
			-- Only validate when field loses focus (not on each keystroke).
		do
			Result := set_validate_on_change (False)
		ensure
			result_is_current: Result = Current
		end

	validate_live: like Current
			-- Validate on each keystroke (default).
		do
			Result := set_validate_on_change (True)
		ensure
			result_is_current: Result = Current
		end

	set_allow_empty (a_allow: BOOLEAN): like Current
			-- Set whether empty field is considered valid.
		do
			allow_empty := a_allow
			validate_input
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	required: like Current
			-- Mark field as required (empty = invalid).
		do
			Result := set_allow_empty (False)
		ensure
			result_is_current: Result = Current
		end

	optional: like Current
			-- Mark field as optional (empty = valid).
		do
			Result := set_allow_empty (True)
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_change (a_action: PROCEDURE)
			-- Set action for text changes.
		require
			action_attached: a_action /= Void
		do
			change_action := a_action
		end

	on_valid (a_action: PROCEDURE)
			-- Set action called when validation passes.
		require
			action_attached: a_action /= Void
		do
			valid_action := a_action
		end

	on_invalid (a_action: PROCEDURE)
			-- Set action called when validation fails.
		require
			action_attached: a_action /= Void
		do
			invalid_action := a_action
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

	when_valid (a_action: PROCEDURE): like Current
			-- Fluent version of on_valid.
		require
			action_attached: a_action /= Void
		do
			on_valid (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	when_invalid (a_action: PROCEDURE): like Current
			-- Fluent version of on_invalid.
		require
			action_attached: a_action /= Void
		do
			on_invalid (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

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

feature -- Theme

	apply_theme
			-- Apply theme colors to field, including validation state.
		do
			ev_text_field.set_font (theme.scaled_font)
			apply_validation_colors
		end

feature -- Validation Colors Configuration

	set_valid_background (a_color: SV_COLOR): like Current
			-- Set custom background color for valid state.
		require
			color_attached: a_color /= Void
		do
			custom_valid_bg := a_color
			apply_validation_colors
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_invalid_background (a_color: SV_COLOR): like Current
			-- Set custom background color for invalid state.
		require
			color_attached: a_color /= Void
		do
			custom_invalid_bg := a_color
			apply_validation_colors
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature {NONE} -- Implementation

	regex: SIMPLE_REGEX
			-- Compiled regex for validation.

	patterns: SIMPLE_REGEX_PATTERNS
			-- Pre-built regex patterns.

	placeholder_text: detachable STRING_32
			-- Placeholder text.

	is_showing_placeholder: BOOLEAN
			-- Is placeholder currently shown?

	validate_on_change: BOOLEAN
			-- Validate on each keystroke?

	allow_empty: BOOLEAN
			-- Is empty field valid?

	change_action: detachable PROCEDURE
			-- Action to call on text change.

	valid_action: detachable PROCEDURE
			-- Action to call when validation passes.

	is_validating: BOOLEAN
			-- Guard flag to prevent reentrant validation.

	invalid_action: detachable PROCEDURE
			-- Action to call when validation fails.

	custom_valid_bg: detachable SV_COLOR
			-- Custom valid background color.

	custom_invalid_bg: detachable SV_COLOR
			-- Custom invalid background color.

	input_mask: detachable STRING_32
			-- Input mask template.
			-- # = digit (0-9)
			-- A = letter (a-zA-Z)
			-- * = alphanumeric
			-- Any other character = literal (auto-inserted)

	is_filtering_input: BOOLEAN
			-- Guard to prevent recursive input filtering.

	on_key_press_string (a_key: STRING_32)
			-- Handle key press to enforce input mask.
		local
			l_pos: INTEGER
			l_mask_char: CHARACTER_32
			l_key_char: CHARACTER_32
			l_current_text: STRING_32
			l_retried: BOOLEAN
		do
			if l_retried or is_filtering_input then
				-- Skip on retry or if already filtering
			elseif attached input_mask as l_mask and then not l_mask.is_empty then
				is_filtering_input := True
				l_current_text := ev_text_field.text
				l_pos := ev_text_field.caret_position

				-- Only process if we're within mask bounds
				if l_pos <= l_mask.count and a_key.count = 1 then
					l_key_char := a_key [1]
					l_mask_char := l_mask [l_pos]

					-- Check if key is valid for this mask position
					if is_valid_for_mask (l_key_char, l_mask_char) then
						-- Key is valid, let it through and auto-insert any following literals
						-- After the character is inserted, check for literals to auto-insert
						-- This is handled in on_text_change via auto_insert_literals
					else
						-- Key is NOT valid - we need to block it
						-- Unfortunately key_press_string_actions doesn't let us block,
						-- so we'll fix it in on_text_change
					end
				end
				is_filtering_input := False
			end
		rescue
			is_filtering_input := False
			l_retried := True
			retry
		end

	is_valid_for_mask (a_char, a_mask_char: CHARACTER_32): BOOLEAN
			-- Is `a_char` valid for mask position expecting `a_mask_char`?
		do
			inspect a_mask_char
			when '#' then
				-- Digit only
				Result := a_char >= '0' and a_char <= '9'
			when 'A' then
				-- Letter only
				Result := (a_char >= 'a' and a_char <= 'z') or (a_char >= 'A' and a_char <= 'Z')
			when '*' then
				-- Alphanumeric
				Result := (a_char >= '0' and a_char <= '9') or
				          (a_char >= 'a' and a_char <= 'z') or
				          (a_char >= 'A' and a_char <= 'Z')
			else
				-- Literal - char must match exactly
				Result := a_char = a_mask_char
			end
		end

	is_mask_placeholder (a_mask_char: CHARACTER_32): BOOLEAN
			-- Is `a_mask_char` a placeholder (not a literal)?
		do
			Result := a_mask_char = '#' or a_mask_char = 'A' or a_mask_char = '*'
		end

	enforce_input_mask
			-- Filter text to match input mask, auto-inserting literals.
		local
			l_current: STRING_32
			l_filtered: STRING_32
			l_mask_pos, l_text_pos: INTEGER
			l_char, l_mask_char: CHARACTER_32
			l_old_caret: INTEGER
			l_new_caret: INTEGER
		do
			if attached input_mask as l_mask and then not l_mask.is_empty then
				is_filtering_input := True
				l_current := ev_text_field.text
				l_old_caret := ev_text_field.caret_position
				create l_filtered.make (l_mask.count)

				-- Build filtered string by matching input against mask
				from
					l_mask_pos := 1
					l_text_pos := 1
				until
					l_mask_pos > l_mask.count or l_text_pos > l_current.count + 1
				loop
					l_mask_char := l_mask [l_mask_pos]

					if is_mask_placeholder (l_mask_char) then
						-- This position expects user input
						if l_text_pos <= l_current.count then
							l_char := l_current [l_text_pos]
							-- Skip any literals the user might have typed (we insert them)
							from
							until
								l_text_pos > l_current.count or not is_literal_in_mask (l_current [l_text_pos], l_mask)
							loop
								l_text_pos := l_text_pos + 1
							end
							if l_text_pos <= l_current.count then
								l_char := l_current [l_text_pos]
								if is_valid_for_mask (l_char, l_mask_char) then
									l_filtered.append_character (l_char)
									l_mask_pos := l_mask_pos + 1
								end
								l_text_pos := l_text_pos + 1
							else
								l_mask_pos := l_mask.count + 1 -- Exit loop
							end
						else
							l_mask_pos := l_mask.count + 1 -- Exit loop
						end
					else
						-- This position is a literal - auto-insert it
						l_filtered.append_character (l_mask_char)
						l_mask_pos := l_mask_pos + 1
						-- If user typed this literal, skip it in input
						if l_text_pos <= l_current.count and then l_current [l_text_pos] = l_mask_char then
							l_text_pos := l_text_pos + 1
						end
					end
				end

				-- Only update if different to avoid infinite loop
				if not l_filtered.same_string (l_current) then
					ev_text_field.set_text (l_filtered)
					-- Restore caret position (adjusted for any added literals)
					l_new_caret := l_filtered.count + 1
					if l_new_caret > 0 and l_new_caret <= l_filtered.count + 1 then
						ev_text_field.set_caret_position (l_new_caret)
					end
				end

				is_filtering_input := False
			end
		end

	is_literal_in_mask (a_char: CHARACTER_32; a_mask: STRING_32): BOOLEAN
			-- Is `a_char` a literal character that appears in the mask?
		local
			i: INTEGER
		do
			from i := 1 until i > a_mask.count or Result loop
				if not is_mask_placeholder (a_mask [i]) and then a_mask [i] = a_char then
					Result := True
				end
				i := i + 1
			end
		end

	validate_input
			-- Validate current text against mask pattern.
		local
			l_text: STRING_32
			l_was_valid: BOOLEAN
			l_match: SIMPLE_REGEX_MATCH
			l_retried: BOOLEAN
		do
			-- Guard against reentrant calls (can happen when events overlap)
			if is_validating then
				-- Skip - already validating
			elseif l_retried then
				is_validating := False
			else
				is_validating := True
				l_was_valid := is_valid
				l_text := text

				if l_text.is_empty then
					is_valid := allow_empty
				elseif regex.is_compiled then
					l_match := regex.match (l_text)
					is_valid := l_match.is_matched
				else
					is_valid := True -- No mask = always valid
				end

				apply_validation_colors
				-- Fire validation events on state change
				if is_valid and not l_was_valid then
					if attached valid_action as va then
						va.call (Void)
					end
				elseif not is_valid and l_was_valid then
					if attached invalid_action as ia then
						ia.call (Void)
					end
				end

				is_validating := False
			end
		rescue
			l_retried := True
			is_valid := False -- Mark as invalid on exception
			is_validating := False
			retry
		end

	apply_validation_colors
			-- Apply colors based on validation state.
		local
			l_bg: SV_COLOR
			l_fg: SV_COLOR
		do
			if is_showing_placeholder then
				l_bg := tokens.surface
				l_fg := tokens.text_hint
			elseif is_valid then
				if attached custom_valid_bg as cvb then
					l_bg := cvb
				else
					l_bg := tokens.surface
				end
				l_fg := tokens.text_primary
			else
				if attached custom_invalid_bg as cib then
					l_bg := cib
				else
					-- Use light tint of error color (blend with surface)
					l_bg := error_background_color
				end
				l_fg := tokens.error
			end

			ev_text_field.set_background_color (l_bg.to_ev_color)
			ev_text_field.set_foreground_color (l_fg.to_ev_color)
		end

	error_background_color: SV_COLOR
			-- Light background color for invalid state.
			-- Blends error color with surface at 10% opacity.
		local
			l_err, l_surf: SV_COLOR
			l_r, l_g, l_b: INTEGER
		do
			l_err := tokens.error
			l_surf := tokens.surface
			-- Simple alpha blend: result = (error * 0.1) + (surface * 0.9)
			l_r := ((l_err.red * 0.1) + (l_surf.red * 0.9)).rounded.min (255).max (0)
			l_g := ((l_err.green * 0.1) + (l_surf.green * 0.9)).rounded.min (255).max (0)
			l_b := ((l_err.blue * 0.1) + (l_surf.blue * 0.9)).rounded.min (255).max (0)
			create Result.make_rgb (l_r, l_g, l_b)
		end

	show_placeholder
			-- Display placeholder text in subdued color.
		do
			if attached placeholder_text as pt and then not pt.is_empty then
				is_showing_placeholder := True  -- Set BEFORE set_text to avoid validation callback
				ev_text_field.set_text (pt)
				ev_text_field.set_foreground_color (tokens.text_hint.to_ev_color)
			end
		end

	hide_placeholder
			-- Remove placeholder and restore normal colors.
		do
			if is_showing_placeholder then
				is_showing_placeholder := False  -- Set BEFORE set_text to avoid callback issues
				ev_text_field.set_text ("")
				apply_validation_colors
			end
		end

	on_focus_in
			-- Handle focus entering field.
		do
			if is_showing_placeholder then
				hide_placeholder
			end
		end

	on_focus_out
			-- Handle focus leaving field.
		local
			l_text: STRING_32
			l_retried: BOOLEAN
		do
			if not l_retried then
				l_text := ev_text_field.text
				if l_text.is_empty and has_placeholder then
					show_placeholder
				else
					validate_input
				end
			end
		rescue
			l_retried := True
			retry
		end

	on_text_change
			-- Handle text changes during editing.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				-- Enforce input mask if defined
				if not is_filtering_input and not is_showing_placeholder then
					enforce_input_mask
				end
				if validate_on_change and not is_showing_placeholder then
					validate_input
				end
				if attached change_action as ca then
					ca.call (Void)
				end
				notify_change
			end
		rescue
			l_retried := True
			retry
		end

	notify_change
			-- Notify harness of text change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("text", "", text.to_string_8))
				notify_event (create {SV_EVENT}.make_state_change ("is_valid", "", is_valid.out))
			end
		end

invariant
	ev_text_field_exists: ev_text_field /= Void
	regex_exists: regex /= Void
	patterns_exists: patterns /= Void

end
