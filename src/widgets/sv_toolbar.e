note
	description: "Toolbar widget - wraps EV_TOOL_BAR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TOOLBAR

inherit
	SV_WIDGET

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty toolbar.
		do
			create ev_tool_bar
			create buttons.make (10)
		end

feature -- Access

	ev_tool_bar: EV_TOOL_BAR
			-- Underlying EiffelVision-2 tool bar.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_tool_bar
		end

	buttons: ARRAYED_LIST [SV_TOOLBAR_BUTTON]
			-- All buttons in toolbar.

	count: INTEGER
			-- Number of buttons.
		do
			Result := buttons.count
		end

feature -- Button Management

	add_button (a_button: SV_TOOLBAR_BUTTON)
			-- Add a button to the toolbar.
		require
			button_attached: a_button /= Void
		do
			ev_tool_bar.extend (a_button.ev_tool_bar_button)
			buttons.extend (a_button)
		ensure
			added: count = old count + 1
		end

	button (a_label: STRING): SV_TOOLBAR_BUTTON
			-- Create and add a button (fluent).
		require
			label_not_empty: not a_label.is_empty
		do
			create Result.make (a_label)
			add_button (Result)
		ensure
			added: count = old count + 1
		end

	button_with_action (a_label: STRING; a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Create and add a button with action.
		require
			label_not_empty: not a_label.is_empty
			action_attached: a_action /= Void
		do
			create Result.make (a_label)
			Result.on_click (a_action)
			add_button (Result)
		end

	separator
			-- Add a separator.
		local
			l_sep: EV_TOOL_BAR_SEPARATOR
		do
			create l_sep
			ev_tool_bar.extend (l_sep)
		end

feature -- Standard Buttons

	new_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "New" button.
		do
			Result := button_with_action ("New", a_action)
		end

	open_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "Open" button.
		do
			Result := button_with_action ("Open", a_action)
		end

	save_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "Save" button.
		do
			Result := button_with_action ("Save", a_action)
		end

	cut_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "Cut" button.
		do
			Result := button_with_action ("Cut", a_action)
		end

	copy_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "Copy" button.
		do
			Result := button_with_action ("Copy", a_action)
		end

	paste_button (a_action: PROCEDURE): SV_TOOLBAR_BUTTON
			-- Add "Paste" button.
		do
			Result := button_with_action ("Paste", a_action)
		end

invariant
	ev_tool_bar_exists: ev_tool_bar /= Void
	buttons_exists: buttons /= Void

end
