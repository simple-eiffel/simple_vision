note
	description: "Tabbed panel container - wraps EV_NOTEBOOK"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TAB_PANEL

inherit
	SV_WIDGET

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty tab panel.
		do
			create ev_notebook
			create tab_widgets.make (5)
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_notebook: EV_NOTEBOOK
			-- Underlying EiffelVision-2 notebook.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_notebook
		end

	tab_widgets: ARRAYED_LIST [SV_WIDGET]
			-- Widgets in each tab.

	count: INTEGER
			-- Number of tabs.
		do
			Result := ev_notebook.count
		end

	selected_index: INTEGER
			-- Index of selected tab (1-based, 0 if none).
		do
			if attached ev_notebook.selected_item as item then
				Result := ev_notebook.index_of (item, 1)
			end
		end

	selected_tab: detachable SV_WIDGET
			-- Currently selected tab content.
		do
			if selected_index > 0 and selected_index <= tab_widgets.count then
				Result := tab_widgets [selected_index]
			end
		end

feature -- Tab Management

	add_tab (a_title: STRING; a_content: SV_WIDGET)
			-- Add a tab with title and content.
		require
			title_not_empty: not a_title.is_empty
			content_attached: a_content /= Void
		do
			ev_notebook.extend (a_content.ev_widget)
			ev_notebook.set_item_text (a_content.ev_widget, a_title)
			tab_widgets.extend (a_content)
		ensure
			added: count = old count + 1
		end

	tab (a_title: STRING; a_content: SV_WIDGET): like Current
			-- Add a tab (fluent).
		require
			title_not_empty: not a_title.is_empty
			content_attached: a_content /= Void
		do
			add_tab (a_title, a_content)
			Result := Current
		ensure
			added: count = old count + 1
			result_is_current: Result = Current
		end

	add_tabs (a_tabs: ARRAY [TUPLE [title: STRING; content: SV_WIDGET]]): like Current
			-- Add multiple tabs.
		require
			tabs_attached: a_tabs /= Void
		do
			across a_tabs as t loop
				add_tab (t.item.title, t.item.content)
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	remove_tab (a_index: INTEGER)
			-- Remove tab at index.
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			ev_notebook.go_i_th (a_index)
			ev_notebook.remove
			tab_widgets.go_i_th (a_index)
			tab_widgets.remove
		ensure
			removed: count = old count - 1
		end

	clear
			-- Remove all tabs.
		do
			ev_notebook.wipe_out
			tab_widgets.wipe_out
		ensure
			empty: count = 0
		end

feature -- Tab Titles

	set_tab_title (a_index: INTEGER; a_title: STRING)
			-- Set title for tab at index.
		require
			valid_index: a_index >= 1 and a_index <= count
			title_not_empty: not a_title.is_empty
		do
			ev_notebook.set_item_text (ev_notebook.i_th (a_index), a_title)
		end

	tab_title (a_index: INTEGER): STRING_32
			-- Get title of tab at index.
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			Result := ev_notebook.item_text (ev_notebook.i_th (a_index))
		end

feature -- Selection

	select_tab (a_index: INTEGER)
			-- Select tab by index.
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			ev_notebook.select_item (ev_notebook.i_th (a_index))
			notify_selection_change
		ensure
			selected: selected_index = a_index
		end

	select_first
			-- Select first tab.
		require
			not_empty: count > 0
		do
			select_tab (1)
		end

	select_last
			-- Select last tab.
		require
			not_empty: count > 0
		do
			select_tab (count)
		end

	select_next
			-- Select next tab (wraps around).
		require
			not_empty: count > 0
		do
			if selected_index < count then
				select_tab (selected_index + 1)
			else
				select_tab (1)
			end
		end

	select_previous
			-- Select previous tab (wraps around).
		require
			not_empty: count > 0
		do
			if selected_index > 1 then
				select_tab (selected_index - 1)
			else
				select_tab (count)
			end
		end

	selected (a_index: INTEGER): like Current
			-- Select tab by index (fluent).
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			select_tab (a_index)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Tab Position

	tabs_on_top: like Current
			-- Position tabs at top (default).
		do
			ev_notebook.set_tab_position ({EV_NOTEBOOK}.tab_top)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	tabs_on_bottom: like Current
			-- Position tabs at bottom.
		do
			ev_notebook.set_tab_position ({EV_NOTEBOOK}.tab_bottom)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	tabs_on_left: like Current
			-- Position tabs on left.
		do
			ev_notebook.set_tab_position ({EV_NOTEBOOK}.tab_left)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	tabs_on_right: like Current
			-- Position tabs on right.
		do
			ev_notebook.set_tab_position ({EV_NOTEBOOK}.tab_right)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_tab_change (a_action: PROCEDURE)
			-- Set action for tab selection change.
		require
			action_attached: a_action /= Void
		do
			ev_notebook.selection_actions.extend (a_action)
		end

	tab_changed (a_action: PROCEDURE): like Current
			-- Fluent version of on_tab_change.
		require
			action_attached: a_action /= Void
		do
			on_tab_change (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	on_tab_select (a_action: PROCEDURE [INTEGER]): like Current
			-- Set action that receives the selected tab index.
		require
			action_attached: a_action /= Void
		do
			ev_notebook.selection_actions.extend (agent (act: PROCEDURE [INTEGER])
				do
					act.call ([selected_index])
				end (a_action))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature {NONE} -- Implementation

	notify_selection_change
			-- Notify harness of tab change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("tab", "", selected_index.out))
			end
		end

invariant
	ev_notebook_exists: ev_notebook /= Void
	tab_widgets_exists: tab_widgets /= Void
	counts_match: count = tab_widgets.count

end
