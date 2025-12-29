note
	description: "Menu bar widget - wraps EV_MENU_BAR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MENU_BAR

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty menu bar.
		do
			create ev_menu_bar
			create menus.make (5)
		end

feature -- Access

	ev_menu_bar: EV_MENU_BAR
			-- Underlying EiffelVision-2 menu bar.

	menus: ARRAYED_LIST [SV_MENU]
			-- All menus in bar.

	count: INTEGER
			-- Number of menus.
		do
			Result := menus.count
		end

feature -- Menu Management

	add_menu (a_menu: SV_MENU)
			-- Add a menu to the bar.
		require
			menu_attached: a_menu /= Void
		do
			ev_menu_bar.extend (a_menu.ev_menu)
			menus.extend (a_menu)
		ensure
			added: count = old count + 1
		end

	menu (a_title: STRING): SV_MENU
			-- Create and add a menu with title (fluent).
		require
			title_not_empty: not a_title.is_empty
		do
			create Result.make (a_title)
			add_menu (Result)
		ensure
			added: count = old count + 1
		end

	file_menu: SV_MENU
			-- Create standard File menu.
		do
			Result := menu ("File")
		end

	edit_menu: SV_MENU
			-- Create standard Edit menu.
		do
			Result := menu ("Edit")
		end

	view_menu: SV_MENU
			-- Create standard View menu.
		do
			Result := menu ("View")
		end

	help_menu: SV_MENU
			-- Create standard Help menu.
		do
			Result := menu ("Help")
		end

feature -- Standard Menus

	with_standard_menus: like Current
			-- Add File, Edit, View, Help menus.
		do
			file_menu.do_nothing
			edit_menu.do_nothing
			view_menu.do_nothing
			help_menu.do_nothing
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	ev_menu_bar_exists: ev_menu_bar /= Void
	menus_exists: menus /= Void

end
