note
	description: "Form field with validation support - connects a widget to validation rules"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_FIELD

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create field with given name.
		require
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			label := a_name -- Default label is name
			create string_rules.make (5)
			create any_rules.make (5)
			placeholder := ""
			help_text := ""
			widget_type := Widget_text_field
			is_touched := False
			is_dirty := False
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Identity

	name: STRING
			-- Field identifier (used for form values).

	label: STRING
			-- Display label for the field.

	set_label (a_label: STRING): like Current
			-- Set display label.
		require
			label_not_empty: not a_label.is_empty
		do
			label := a_label
			Result := Current
		ensure
			label_set: label.same_string (a_label)
			result_is_current: Result = Current
		end

feature -- Value

	value: STRING_32
			-- Current field value.
		do
			if attached widget as w then
				if attached {SV_TEXT_FIELD} w as tf then
					Result := tf.text
				elseif attached {SV_MASKED_FIELD} w as mf then
					Result := mf.text
				elseif attached {SV_DROPDOWN} w as dd then
					Result := dd.selected_text
				elseif attached {SV_CHECKBOX} w as cb then
					Result := cb.is_checked.out
				else
					Result := ""
				end
			else
				create Result.make_empty
			end
		end

	set_value (a_value: READABLE_STRING_GENERAL)
			-- Set field value programmatically.
		require
			value_not_void: a_value /= Void
		do
			if attached widget as w then
				if attached {SV_TEXT_FIELD} w as tf then
					tf.set_text (a_value)
				elseif attached {SV_MASKED_FIELD} w as mf then
					mf.set_text (a_value)
				end
			end
			is_dirty := True
		end

	default_value: STRING_32
			-- Default value for reset.
		attribute
			create Result.make_empty
		end

	set_default (a_value: READABLE_STRING_GENERAL): like Current
			-- Set default value.
		require
			value_not_void: a_value /= Void
		do
			default_value := a_value.to_string_32
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Validation Rules

	required: like Current
			-- Add required validation.
		do
			any_rules.extend (create {SV_REQUIRED_RULE})
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	min_length (a_min: INTEGER): like Current
			-- Add minimum length validation.
		require
			positive: a_min >= 0
		do
			string_rules.extend (create {SV_MIN_LENGTH_RULE}.make (a_min))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	max_length (a_max: INTEGER): like Current
			-- Add maximum length validation.
		require
			positive: a_max > 0
		do
			string_rules.extend (create {SV_MAX_LENGTH_RULE}.make (a_max))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	pattern (a_regex: STRING): like Current
			-- Add pattern validation.
		require
			pattern_not_empty: not a_regex.is_empty
		do
			string_rules.extend (create {SV_PATTERN_RULE}.make (a_regex))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	pattern_with_message (a_regex: STRING; a_message: STRING): like Current
			-- Add pattern validation with custom message.
		require
			pattern_not_empty: not a_regex.is_empty
			message_not_empty: not a_message.is_empty
		do
			string_rules.extend (create {SV_PATTERN_RULE}.make_with_message (a_regex, a_message))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	email: like Current
			-- Add email validation.
		do
			string_rules.extend (create {SV_EMAIL_RULE}.make)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	custom (a_validator: FUNCTION [STRING_32, BOOLEAN]; a_message: STRING): like Current
			-- Add custom validation function.
		require
			validator_attached: a_validator /= Void
			message_not_empty: not a_message.is_empty
		do
			custom_validator := a_validator
			custom_validator_message := a_message
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Validation

	validate: BOOLEAN
			-- Validate current value against all rules. Sets error_message if invalid.
		local
			l_value: STRING_32
		do
			l_value := value
			Result := True
			error_message := Void

			-- Check any-type rules (required)
			across any_rules as rule loop
				if not rule.item.validate (l_value) then
					Result := False
					error_message := rule.item.message
				end
			end

			-- Check string rules (only if value is non-empty)
			if Result and then not l_value.is_empty then
				across string_rules as rule loop
					if Result and then not rule.item.validate (l_value) then
						Result := False
						error_message := rule.item.message
					end
				end
			end

			-- Check custom validator
			if Result and then attached custom_validator as cv then
				if not cv.item ([l_value]) then
					Result := False
					error_message := custom_validator_message
				end
			end

			is_valid := Result
		end

	is_valid: BOOLEAN
			-- Did last validation pass?

	error_message: detachable STRING
			-- Error message from last failed validation.

feature -- UI Hints

	placeholder: STRING
			-- Placeholder text for the widget.

	set_placeholder (a_text: STRING): like Current
			-- Set placeholder text.
		require
			text_not_void: a_text /= Void
		do
			placeholder := a_text
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	help_text: STRING
			-- Help text shown below field.

	set_help_text (a_text: STRING): like Current
			-- Set help text.
		require
			text_not_void: a_text /= Void
		do
			help_text := a_text
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	widget_type: INTEGER
			-- Type of widget to create.

	as_text_field: like Current
			-- Use text field widget.
		do
			widget_type := Widget_text_field
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	as_text_area: like Current
			-- Use multi-line text area widget.
		do
			widget_type := Widget_text_area
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	as_password: like Current
			-- Use password field widget.
		do
			widget_type := Widget_password
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	as_dropdown (a_options: ARRAY [STRING]): like Current
			-- Use dropdown widget with options.
		require
			options_not_empty: not a_options.is_empty
		do
			widget_type := Widget_dropdown
			options := a_options
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	as_checkbox: like Current
			-- Use checkbox widget.
		do
			widget_type := Widget_checkbox
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	as_masked (a_pattern: STRING): like Current
			-- Use masked field widget.
		require
			pattern_not_empty: not a_pattern.is_empty
		do
			widget_type := Widget_masked
			mask_pattern := a_pattern
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	options: detachable ARRAY [STRING]
			-- Options for dropdown.

	mask_pattern: detachable STRING
			-- Mask pattern for masked field.

feature -- State

	is_touched: BOOLEAN
			-- Has user interacted with field?

	mark_touched
			-- Mark field as touched.
		do
			is_touched := True
		ensure
			touched: is_touched
		end

	is_dirty: BOOLEAN
			-- Has value changed from default?

	reset
			-- Reset to default value.
		do
			set_value (default_value)
			is_dirty := False
			is_touched := False
			is_valid := True
			error_message := Void
		ensure
			not_dirty: not is_dirty
			not_touched: not is_touched
		end

feature -- Widget

	widget: detachable SV_WIDGET
			-- The actual UI widget for this field.

	attach_widget (a_widget: SV_WIDGET)
			-- Attach a widget to this field.
		require
			widget_attached: a_widget /= Void
		do
			widget := a_widget
			-- Wire up touch detection
			if attached {SV_TEXT_FIELD} a_widget as tf then
				tf.ev_text_field.focus_out_actions.extend (agent mark_touched)
			end
		ensure
			widget_set: widget = a_widget
		end

feature -- Widget Type Constants

	Widget_text_field: INTEGER = 1
	Widget_text_area: INTEGER = 2
	Widget_password: INTEGER = 3
	Widget_dropdown: INTEGER = 4
	Widget_checkbox: INTEGER = 5
	Widget_masked: INTEGER = 6

feature {NONE} -- Implementation

	string_rules: ARRAYED_LIST [SV_VALIDATION_RULE [READABLE_STRING_GENERAL]]
			-- String validation rules.

	any_rules: ARRAYED_LIST [SV_VALIDATION_RULE [detachable ANY]]
			-- General validation rules.

	custom_validator: detachable FUNCTION [STRING_32, BOOLEAN]
			-- Custom validation function.

	custom_validator_message: detachable STRING
			-- Message for custom validator failure.

invariant
	name_not_empty: not name.is_empty
	label_not_empty: not label.is_empty

end
