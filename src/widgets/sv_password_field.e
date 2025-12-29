note
	description: "Password field - wraps EV_PASSWORD_FIELD"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_PASSWORD_FIELD

inherit
	SV_WIDGET

create
	make,
	make_with_text

feature {NONE} -- Initialization

	make
			-- Create empty password field.
		do
			create ev_password_field
			ev_widget := ev_password_field
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create password field with initial text.
		require
			text_not_void: a_text /= Void
		do
			make
			ev_password_field.set_text (a_text)
		end

feature -- Access

	ev_password_field: EV_PASSWORD_FIELD
			-- Underlying EiffelVision-2 password field.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	text: STRING_32
			-- Current text content.
		do
			Result := ev_password_field.text
		end

	is_empty: BOOLEAN
			-- Is field empty?
		do
			Result := text.is_empty
		end

feature -- Modification

	set_text (a_text: READABLE_STRING_GENERAL)
			-- Set field text.
		require
			text_not_void: a_text /= Void
		do
			ev_password_field.set_text (a_text)
		end

	clear
			-- Clear the field.
		do
			ev_password_field.remove_text
		ensure
			is_empty: is_empty
		end

feature -- Fluent Configuration

	content (a_text: READABLE_STRING_GENERAL): like Current
			-- Set initial content (fluent).
		require
			text_not_void: a_text /= Void
		do
			set_text (a_text)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	placeholder (a_text: STRING): like Current
			-- Set placeholder text (fluent).
		require
			text_not_empty: not a_text.is_empty
		do
			-- EV_PASSWORD_FIELD doesn't have placeholder, but we can set tooltip
			ev_password_field.set_tooltip (a_text)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_change (a_action: PROCEDURE)
			-- Call action when text changes.
		require
			action_attached: a_action /= Void
		do
			ev_password_field.change_actions.extend (agent (act: PROCEDURE)
				do
					act.call (Void)
				end (a_action))
		end

	on_enter (a_action: PROCEDURE)
			-- Call action when Enter is pressed.
		require
			action_attached: a_action /= Void
		do
			ev_password_field.return_actions.extend (agent (act: PROCEDURE)
				do
					act.call (Void)
				end (a_action))
		end

invariant
	ev_password_field_exists: ev_password_field /= Void

end
