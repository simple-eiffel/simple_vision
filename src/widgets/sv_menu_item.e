note
	description: "Menu item widget - wraps EV_MENU_ITEM"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MENU_ITEM

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make (a_label: STRING)
			-- Create menu item with label.
		require
			label_not_empty: not a_label.is_empty
		do
			create ev_menu_item.make_with_text (a_label)
		ensure
			label_set: label.same_string (a_label)
		end

feature -- Access

	ev_menu_item: EV_MENU_ITEM
			-- Underlying EiffelVision-2 menu item.

	label: STRING_32
			-- Item label.
		do
			Result := ev_menu_item.text
		end

feature -- Label

	set_label (a_label: STRING)
			-- Set item label.
		require
			label_not_empty: not a_label.is_empty
		do
			ev_menu_item.set_text (a_label)
		ensure
			label_set: label.same_string (a_label)
		end

feature -- State

	enable
			-- Enable the item.
		do
			ev_menu_item.enable_sensitive
		end

	disable
			-- Disable the item.
		do
			ev_menu_item.disable_sensitive
		end

	is_enabled: BOOLEAN
			-- Is item enabled?
		do
			Result := ev_menu_item.is_sensitive
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
			ev_menu_item.select_actions.extend (a_action)
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
	ev_menu_item_exists: ev_menu_item /= Void

end
