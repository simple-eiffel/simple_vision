note
	description: "List widget - backed by EV_GRID for font support"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_LIST

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_items

feature {NONE} -- Initialization

	make
			-- Create empty list.
		do
			create ev_grid
			ev_grid.set_column_count_to (1)
			ev_grid.hide_header
			ev_grid.enable_single_row_selection
			ev_grid.enable_always_selected
			ev_grid.set_focused_selection_color (create {EV_COLOR}.make_with_8_bit_rgb (200, 200, 240))
			ev_grid.set_focused_selection_text_color (create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 0))
			ev_grid.set_non_focused_selection_color (create {EV_COLOR}.make_with_8_bit_rgb (220, 220, 220))
			ev_grid.set_non_focused_selection_text_color (create {EV_COLOR}.make_with_8_bit_rgb (0, 0, 0))
			create item_values.make (20)
			apply_theme
			subscribe_to_theme
		end

	make_with_items (a_items: ARRAY [READABLE_STRING_GENERAL])
			-- Create list with items.
		require
			items_attached: a_items /= Void
		do
			make
			across a_items as ic_item loop
				add_item (ic_item.item)
			end
		end

feature -- Access

	ev_grid: EV_GRID
			-- Underlying EiffelVision-2 grid (used instead of EV_LIST for font support).

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_grid
		end

	item_values: ARRAYED_LIST [STRING_32]
			-- Values associated with each item.

	count: INTEGER
			-- Number of items.
		do
			Result := ev_grid.row_count
		end

	is_empty: BOOLEAN
			-- Is list empty?
		do
			Result := ev_grid.row_count = 0
		end

feature -- Selection

	selected_index: INTEGER
			-- Index of selected item (0 if none).
		do
			if ev_grid.selected_rows.count > 0 then
				Result := ev_grid.selected_rows.first.index
			end
		end

	selected_text: STRING_32
			-- Text of selected item.
		do
			if ev_grid.selected_rows.count > 0 then
				if attached {EV_GRID_LABEL_ITEM} ev_grid.selected_rows.first.item (1) as al_item then
					Result := al_item.text
				else
					Result := {STRING_32} ""
				end
			else
				Result := {STRING_32} ""
			end
		end

	selected_value: STRING_32
			-- Value of selected item.
		do
			if selected_index > 0 and selected_index <= item_values.count then
				Result := item_values [selected_index]
			else
				Result := {STRING_32} ""
			end
		end

	has_selection: BOOLEAN
			-- Is any item selected?
		do
			Result := ev_grid.selected_rows.count > 0
		end

feature -- Items

	add_item (a_text: READABLE_STRING_GENERAL)
			-- Add an item.
		require
			text_not_empty: not a_text.is_empty
		local
			l_item: EV_GRID_LABEL_ITEM
		do
			ev_grid.insert_new_row (ev_grid.row_count + 1)
			create l_item.make_with_text (a_text.to_string_32)
			l_item.set_font (theme.scaled_font)
			ev_grid.row (ev_grid.row_count).set_item (1, l_item)
			item_values.extend (a_text.to_string_32)
		ensure
			added: count = old count + 1
		end

	add_item_with_value (a_text, a_value: READABLE_STRING_GENERAL)
			-- Add item with separate display text and value.
		require
			text_not_empty: not a_text.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_item: EV_GRID_LABEL_ITEM
		do
			ev_grid.insert_new_row (ev_grid.row_count + 1)
			create l_item.make_with_text (a_text.to_string_32)
			l_item.set_font (theme.scaled_font)
			ev_grid.row (ev_grid.row_count).set_item (1, l_item)
			item_values.extend (a_value.to_string_32)
		end

	items (a_items: ARRAY [READABLE_STRING_GENERAL]): like Current
			-- Add multiple items (fluent).
		require
			items_attached: a_items /= Void
		do
			across a_items as ic_item loop
				add_item (ic_item.item)
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear
			-- Remove all items.
		do
			ev_grid.wipe_out
			ev_grid.set_column_count_to (1)
			item_values.wipe_out
		ensure
			empty: is_empty
		end

	remove_selected
			-- Remove selected item.
		require
			has_selection: has_selection
		local
			l_idx: INTEGER
		do
			l_idx := selected_index
			if l_idx > 0 then
				ev_grid.remove_row (l_idx)
				if l_idx <= item_values.count then
					item_values.go_i_th (l_idx)
					item_values.remove
				end
			end
		end

feature -- Selection Operations

	select_index (a_index: INTEGER)
			-- Select item by index.
		require
			valid_index: a_index >= 1 and a_index <= count
		do
			ev_grid.row (a_index).enable_select
			notify_selection_change
		end

	select_value (a_value: READABLE_STRING_GENERAL)
			-- Select item by value.
		require
			value_not_empty: not a_value.is_empty
		local
			i: INTEGER
		do
			from i := 1 until i > item_values.count loop
				if item_values [i].same_string_general (a_value) then
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
			ev_grid.remove_selection
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
			ev_grid.enable_multiple_row_selection
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	disable_multiple_selection: like Current
			-- Only allow single selection.
		do
			ev_grid.enable_single_row_selection
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
			across ev_grid.selected_rows as ic_row loop
				Result.extend (ic_row.item.index)
			end
		end

feature -- Events

	on_select (a_action: PROCEDURE)
			-- Set action for selection change.
		require
			action_attached: a_action /= Void
		do
			ev_grid.row_select_actions.extend (agent (a_row: EV_GRID_ROW; act: PROCEDURE)
				do
					act.call (Void)
				end (?, a_action))
		end

	on_deselect (a_action: PROCEDURE)
			-- Set action for deselection.
		require
			action_attached: a_action /= Void
		do
			ev_grid.row_deselect_actions.extend (agent (a_row: EV_GRID_ROW; act: PROCEDURE)
				do
					act.call (Void)
				end (?, a_action))
		end

	on_double_click (a_action: PROCEDURE)
			-- Set action for double-click.
		require
			action_attached: a_action /= Void
		do
			ev_grid.pointer_double_press_actions.extend (agent (x, y, b: INTEGER; xt, yt, p: REAL_64; sx, sy: INTEGER; act: PROCEDURE)
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

feature -- Theme

	apply_theme
			-- Apply theme colors and font to list.
		local
			i: INTEGER
		do
			ev_grid.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_grid.set_background_color (tokens.surface.to_ev_color)
			-- Update font on all existing items
			from i := 1 until i > ev_grid.row_count loop
				if attached {EV_GRID_LABEL_ITEM} ev_grid.row (i).item (1) as al_item then
					al_item.set_font (theme.scaled_font)
				end
				i := i + 1
			end
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
	ev_grid_exists: ev_grid /= Void
	item_values_exists: item_values /= Void

end
