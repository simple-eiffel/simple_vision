note
	description: "Form container managing multiple fields with validation"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_FORM

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty form.
		do
			create fields.make (10)
			create field_order.make (10)
			create groups.make (5)
			create errors.make (10)
			create submit_actions.make
			create error_actions.make
			create change_actions.make
		end

feature -- Structure

	add_field (a_field: SV_FIELD)
			-- Add field to form.
		require
			field_attached: a_field /= Void
			unique_name: not has_field (a_field.name)
		do
			fields.put (a_field, a_field.name)
			field_order.extend (a_field.name)
		ensure
			field_added: has_field (a_field.name)
		end

	add_fields (a_fields: ARRAY [SV_FIELD])
			-- Add multiple fields.
		require
			fields_not_empty: not a_fields.is_empty
		do
			across a_fields as f loop
				add_field (f.item)
			end
		end

	add_group (a_name: STRING; a_field_names: ARRAY [STRING])
			-- Group fields together for display.
		require
			name_not_empty: not a_name.is_empty
			fields_exist: across a_field_names as fn all has_field (fn.item) end
		do
			groups.put (a_field_names, a_name)
		ensure
			group_added: groups.has (a_name)
		end

	field (a_name: STRING): detachable SV_FIELD
			-- Get field by name.
		require
			name_not_empty: not a_name.is_empty
		do
			Result := fields.item (a_name)
		end

	has_field (a_name: STRING): BOOLEAN
			-- Does form have field with this name?
		require
			name_not_empty: not a_name.is_empty
		do
			Result := fields.has (a_name)
		end

feature -- Values

	values: HASH_TABLE [STRING_32, STRING]
			-- All field values as name -> value table.
		do
			create Result.make (fields.count)
			across field_order as fn loop
				if attached fields.item (fn.item) as f then
					Result.put (f.value, f.name)
				end
			end
		end

	set_values (a_values: HASH_TABLE [READABLE_STRING_GENERAL, STRING])
			-- Populate form from values table.
		require
			values_attached: a_values /= Void
		do
			across a_values as v loop
				if attached fields.item (v.key) as f then
					f.set_value (v.item)
				end
			end
		end

	value_of (a_field_name: STRING): STRING_32
			-- Get value of specific field.
		require
			field_exists: has_field (a_field_name)
		do
			if attached field (a_field_name) as f then
				Result := f.value
			else
				create Result.make_empty
			end
		end

	reset
			-- Clear all fields to defaults.
		do
			across fields as f loop
				f.item.reset
			end
			errors.wipe_out
			is_submitting := False
		end

feature -- Validation

	validate: BOOLEAN
			-- Run all validations, return True if all pass.
		do
			errors.wipe_out
			Result := True

			across fields as f loop
				if not f.item.validate then
					Result := False
					if attached f.item.error_message as msg then
						errors.put (msg, f.item.name)
					end
				end
			end

			is_valid := Result
		end

	validate_field (a_name: STRING): BOOLEAN
			-- Validate single field.
		require
			field_exists: has_field (a_name)
		do
			if attached field (a_name) as f then
				Result := f.validate
				if not Result and then attached f.error_message as msg then
					errors.put (msg, f.name)
				else
					errors.remove (f.name)
				end
			end
		end

	is_valid: BOOLEAN
			-- Did last validation pass?

	errors: HASH_TABLE [STRING, STRING]
			-- Field name -> error message for failed validations.

	error_for (a_field_name: STRING): detachable STRING
			-- Get error message for specific field.
		require
			name_not_empty: not a_field_name.is_empty
		do
			Result := errors.item (a_field_name)
		end

feature -- Submission

	submit
			-- Validate and fire on_submit or on_error.
		do
			if validate then
				is_submitting := True
				submit_actions.call ([values])
				is_submitting := False
			else
				error_actions.call ([errors])
			end
		end

	on_submit (a_action: PROCEDURE [HASH_TABLE [STRING_32, STRING]])
			-- Set action for successful submission.
		require
			action_attached: a_action /= Void
		do
			submit_actions.extend (a_action)
		end

	on_error (a_action: PROCEDURE [HASH_TABLE [STRING, STRING]])
			-- Set action for validation errors.
		require
			action_attached: a_action /= Void
		do
			error_actions.extend (a_action)
		end

	on_change (a_action: PROCEDURE)
			-- Set action for any field change.
		require
			action_attached: a_action /= Void
		do
			change_actions.extend (a_action)
		end

feature -- State

	is_dirty: BOOLEAN
			-- Have any values changed since last submit/reset?
		do
			Result := across fields as f some f.item.is_dirty end
		end

	is_submitting: BOOLEAN
			-- Is async submission in progress?

	all_touched: BOOLEAN
			-- Have all fields been touched?
		do
			Result := across fields as f all f.item.is_touched end
		end

	mark_all_touched
			-- Mark all fields as touched (e.g., on submit attempt).
		do
			across fields as f loop
				f.item.mark_touched
			end
		end

feature -- UI Building

	build: SV_WIDGET
			-- Auto-generate form UI from fields.
		local
			l_col: SV_COLUMN
			l_row: SV_ROW
			l_label: SV_TEXT
			l_widget: SV_WIDGET
			l_quick: SV_QUICK
		do
			create l_quick.make
			l_col := l_quick.column.spacing (12).padding (16)

			across field_order as fn loop
				if attached fields.item (fn.item) as fld then
					-- Create label
					l_label := l_quick.text (fld.label).bold

					-- Create appropriate widget
					inspect fld.widget_type
					when {SV_FIELD}.Widget_text_field then
						l_widget := l_quick.text_field.placeholder (fld.placeholder)
						fld.attach_widget (l_widget)
					when {SV_FIELD}.Widget_password then
						l_widget := l_quick.password_field.placeholder (fld.placeholder)
						fld.attach_widget (l_widget)
					when {SV_FIELD}.Widget_masked then
						if attached fld.mask_pattern as mp then
							l_widget := l_quick.masked_field_with (mp).placeholder (fld.placeholder)
							fld.attach_widget (l_widget)
						else
							l_widget := l_quick.text_field
							fld.attach_widget (l_widget)
						end
					when {SV_FIELD}.Widget_dropdown then
						if attached fld.options as opts then
							l_widget := l_quick.dropdown_with (opts)
							fld.attach_widget (l_widget)
						else
							l_widget := l_quick.dropdown
							fld.attach_widget (l_widget)
						end
					when {SV_FIELD}.Widget_checkbox then
						l_widget := l_quick.checkbox (fld.label)
						fld.attach_widget (l_widget)
					else
						l_widget := l_quick.text_field.placeholder (fld.placeholder)
						fld.attach_widget (l_widget)
					end

					-- Add to layout
					l_row := l_quick.row.spacing (8)
					l_row := l_row.add (l_label.min_width (120))
					l_row := l_row.add (l_widget)

					-- Add help text if present
					if not fld.help_text.is_empty then
						l_col := l_col.add (l_row)
						l_col := l_col.add (l_quick.text (fld.help_text).font_size (11))
					else
						l_col := l_col.add (l_row)
					end
				end
			end

			Result := l_col
		end

feature -- Access

	field_count: INTEGER
			-- Number of fields in form.
		do
			Result := fields.count
		end

	field_names: ARRAYED_LIST [STRING]
			-- Names of all fields in order.
		do
			Result := field_order.twin
		end

feature {NONE} -- Implementation

	fields: HASH_TABLE [SV_FIELD, STRING]
			-- Fields by name.

	field_order: ARRAYED_LIST [STRING]
			-- Field names in order added.

	groups: HASH_TABLE [ARRAY [STRING], STRING]
			-- Field groups by name.

	submit_actions: ACTION_SEQUENCE [TUPLE [HASH_TABLE [STRING_32, STRING]]]
			-- Actions on successful submit.

	error_actions: ACTION_SEQUENCE [TUPLE [HASH_TABLE [STRING, STRING]]]
			-- Actions on validation error.

	change_actions: ACTION_SEQUENCE [TUPLE]
			-- Actions on any field change.

invariant
	fields_exist: fields /= Void
	field_order_exists: field_order /= Void
	errors_exist: errors /= Void

end
