note
	description: "Toolbar button widget - wraps EV_TOOL_BAR_BUTTON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TOOLBAR_BUTTON

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make (a_label: STRING)
			-- Create toolbar button with label.
		require
			label_not_empty: not a_label.is_empty
		do
			create ev_tool_bar_button.make_with_text (a_label)
		ensure
			label_set: label.same_string (a_label)
		end

feature -- Access

	ev_tool_bar_button: EV_TOOL_BAR_BUTTON
			-- Underlying EiffelVision-2 tool bar button.

	label: STRING_32
			-- Button label.
		do
			Result := ev_tool_bar_button.text
		end

feature -- Label

	set_label (a_label: STRING)
			-- Set button label.
		require
			label_not_empty: not a_label.is_empty
		do
			ev_tool_bar_button.set_text (a_label)
		ensure
			label_set: label.same_string (a_label)
		end

feature -- Tooltip

	set_tooltip (a_text: STRING)
			-- Set tooltip text.
		require
			text_not_empty: not a_text.is_empty
		do
			ev_tool_bar_button.set_tooltip (a_text)
		end

	tooltip (a_text: STRING): like Current
			-- Set tooltip (fluent).
		require
			text_not_empty: not a_text.is_empty
		do
			set_tooltip (a_text)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- State

	enable
			-- Enable the button.
		do
			ev_tool_bar_button.enable_sensitive
		end

	disable
			-- Disable the button.
		do
			ev_tool_bar_button.disable_sensitive
		end

	is_enabled: BOOLEAN
			-- Is button enabled?
		do
			Result := ev_tool_bar_button.is_sensitive
		end

	enabled: like Current
			-- Enable (fluent).
		do
			enable
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	disabled: like Current
			-- Disable (fluent).
		do
			disable
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_click (a_action: PROCEDURE)
			-- Set action for click.
		require
			action_attached: a_action /= Void
		do
			ev_tool_bar_button.select_actions.extend (a_action)
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

invariant
	ev_tool_bar_button_exists: ev_tool_bar_button /= Void

end
