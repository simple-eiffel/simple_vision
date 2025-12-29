note
	description: "Menu widget - wraps EV_MENU"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MENU

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make (a_title: STRING)
			-- Create menu with title.
		require
			title_not_empty: not a_title.is_empty
		do
			create ev_menu.make_with_text (a_title)
			create items.make (10)
		ensure
			title_set: title.same_string (a_title)
		end

feature -- Access

	ev_menu: EV_MENU
			-- Underlying EiffelVision-2 menu.

	items: ARRAYED_LIST [SV_MENU_ITEM]
			-- All items in menu.

	title: STRING_32
			-- Menu title.
		do
			Result := ev_menu.text
		end

	count: INTEGER
			-- Number of items.
		do
			Result := items.count
		end

feature -- Item Management

	add_item (a_item: SV_MENU_ITEM)
			-- Add an item to the menu.
		require
			item_attached: a_item /= Void
		do
			ev_menu.extend (a_item.ev_menu_item)
			items.extend (a_item)
		ensure
			added: count = old count + 1
		end

	item (a_label: STRING): SV_MENU_ITEM
			-- Create and add a menu item (fluent).
		require
			label_not_empty: not a_label.is_empty
		do
			create Result.make (a_label)
			add_item (Result)
		ensure
			added: count = old count + 1
		end

	item_with_action (a_label: STRING; a_action: PROCEDURE): SV_MENU_ITEM
			-- Create and add a menu item with action.
		require
			label_not_empty: not a_label.is_empty
			action_attached: a_action /= Void
		do
			create Result.make (a_label)
			Result.on_click (a_action)
			add_item (Result)
		end

	separator
			-- Add a separator.
		local
			l_sep: EV_MENU_SEPARATOR
		do
			create l_sep
			ev_menu.extend (l_sep)
		end

feature -- Standard Items

	new_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "New" item.
		do
			Result := item_with_action ("New", a_action)
		end

	open_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Open..." item.
		do
			Result := item_with_action ("Open...", a_action)
		end

	save_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Save" item.
		do
			Result := item_with_action ("Save", a_action)
		end

	save_as_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Save As..." item.
		do
			Result := item_with_action ("Save As...", a_action)
		end

	exit_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Exit" item.
		do
			Result := item_with_action ("Exit", a_action)
		end

	cut_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Cut" item.
		do
			Result := item_with_action ("Cut", a_action)
		end

	copy_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Copy" item.
		do
			Result := item_with_action ("Copy", a_action)
		end

	paste_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "Paste" item.
		do
			Result := item_with_action ("Paste", a_action)
		end

	about_item (a_action: PROCEDURE): SV_MENU_ITEM
			-- Add "About" item.
		do
			Result := item_with_action ("About", a_action)
		end

invariant
	ev_menu_exists: ev_menu /= Void
	items_exists: items /= Void

end
