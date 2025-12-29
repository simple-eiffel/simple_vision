note
	description: "List widget - wraps EV_LIST"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_LIST

inherit
	SV_WIDGET

create
	make,
	make_with_items

feature {NONE} -- Initialization

	make
			-- Create empty list.
		do
			create ev_list
			create item_values.make (20)
		end

	make_with_items (a_items: ARRAY [STRING])
			-- Create list with items.
		require
			items_attached: a_items /= Void
		do
			make
			across a_items as item loop
				add_item (item.item)
			end
		end

feature -- Access

	ev_list: EV_LIST
			-- Underlying EiffelVision-2 list.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_list
		end

	item_values: ARRAYED_LIST [STRING]
			-- Values associated with each item.

	count: INTEGER
			-- Number of items.
		do
			Result := ev_list.count
		end

	is_empty: BOOLEAN
			-- Is list empty?
		do
			Result := ev_list.is_empty
		end

feature -- Selection

	selected_index: INTEGER
			-- Index of selected item (0 if none).
		do
			if attached ev_list.selected_item as item then
				Result := ev_list.index_of (item, 1)
			end
		end

	selected_text: STRING_32
			-- Text of selected item.
		do
			if attached ev_list.selected_item as item then
				Result := item.text
			else
				Result := ""
			end
		end

	selected_value: STRING
			-- Value of selected item.
		do
			if selected_index > 0 and selected_index <= item_values.count then
				Result := item_values [selected_index]
			else
				Result := ""
			end
		end

	has_selection: BOOLEAN
			-- Is any item selected?
		do
			Result := ev_list.selected_item /= Void
		end

feature -- Items

	add_item (a_text: STRING)
			-- Add an item.
		require
			text_not_empty: not a_text.is_empty
		local
			l_item: EV_LIST_ITEM
		do
			create l_item.make_with_text (a_text)
			ev_list.extend (l_item)
			item_values.extend (a_text)
		ensure
			added: count = old count + 1
		end

	add_item_with_value (a_text, a_value: STRING)
			-- Add item with separate display text and value.
		require
			text_not_empty: not a_text.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_item: EV_LIST_ITEM
		do
			create l_item.make_with_text (a_text)
			ev_list.extend (l_item)
			item_values.extend (a_value)
		end

	items (a_items: ARRAY [STRING]): like Current
			-- Add multiple items (fluent).
		require
			items_attached: a_items /= Void
		do
			across a_items as item loop
				add_item (item.item)
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear
			-- Remove all items.
		do
			ev_list.wipe_out
			item_values.wipe_out
		ensure
			empty: is_empty
		end

	remove_selected
			-- Remove selected item.
		require
			has_selection: has_selection
		do
			if attached ev_list.selected_item as item then
				if selected_index <= item_values.count then
					item_values.go_i_th (selected_index)
					item_values.remove
				end
				ev_list.prune (item)
			end
		end

feature -- Selection Operations

	select_index (a_index: INTEGER)
			-- Select item by index.
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			ev_list.i_th (a_index).enable_select
			notify_selection_change
		ensure
			selected: selected_index = a_index
		end

	select_value (a_value: STRING)
			-- Select item by value.
		require
			value_not_empty: not a_value.is_empty
		local
			i: INTEGER
		do
			from i := 1 until i > item_values.count loop
				if item_values [i].same_string (a_value) then
					select_index (i)
				end
				i := i + 1
			end
		end

	select_first
			-- Select first item.
		require
			not_empty: not is_empty
		do
			select_index (1)
		end

	deselect_all
			-- Clear selection.
		do
			ev_list.remove_selection
		ensure
			no_selection: not has_selection
		end

	selected (a_index: INTEGER): like Current
			-- Select item by index (fluent).
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			select_index (a_index)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Multiple Selection

	enable_multiple_selection: like Current
			-- Allow selecting multiple items.
		do
			ev_list.enable_multiple_selection
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	disable_multiple_selection: like Current
			-- Only allow single selection.
		do
			ev_list.disable_multiple_selection
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	multiple_selection: like Current
			-- Fluent alias for enable_multiple_selection.
		do
			Result := enable_multiple_selection
		ensure
			result_is_current: Result = Current
		end

	selected_indices: ARRAYED_LIST [INTEGER]
			-- Indices of all selected items.
		do
			create Result.make (10)
			across ev_list.selected_items as item loop
				Result.extend (ev_list.index_of (item.item, 1))
			end
		end

feature -- Events

	on_select (a_action: PROCEDURE)
			-- Set action for selection change.
		require
			action_attached: a_action /= Void
		do
			ev_list.select_actions.extend (a_action)
		end

	on_deselect (a_action: PROCEDURE)
			-- Set action for deselection.
		require
			action_attached: a_action /= Void
		do
			ev_list.deselect_actions.extend (a_action)
		end

	on_double_click (a_action: PROCEDURE)
			-- Set action for double-click.
		require
			action_attached: a_action /= Void
		do
			ev_list.pointer_double_press_actions.extend (agent (x, y, b: INTEGER; xt, yt, p: REAL_64; sx, sy: INTEGER; act: PROCEDURE)
				do
					act.call (Void)
				end (?, ?, ?, ?, ?, ?, ?, ?, a_action))
		end

	selected_action (a_action: PROCEDURE): like Current
			-- Fluent version of on_select.
		require
			action_attached: a_action /= Void
		do
			on_select (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature {NONE} -- Implementation

	notify_selection_change
			-- Notify harness of selection change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("selection", "", selected_value))
			end
		end

invariant
	ev_list_exists: ev_list /= Void
	item_values_exists: item_values /= Void

end
