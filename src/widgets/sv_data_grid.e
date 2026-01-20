note
	description: "Data grid for tabular data display - wraps EV_GRID"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_DATA_GRID

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_columns

feature {NONE} -- Initialization

	make
			-- Create empty data grid.
		do
			create ev_grid
			ev_widget := ev_grid
			create column_titles.make (10)
			create row_data.make (100)
			sort_column := 0
			sort_direction := Sort_none
			is_striped := False
			apply_theme
			subscribe_to_theme
		end

	make_with_columns (a_columns: ARRAY [STRING])
			-- Create grid with column headers.
		require
			columns_attached: a_columns /= Void
			columns_not_empty: not a_columns.is_empty
		do
			make
			set_columns (a_columns)
		end

feature -- Access

	ev_grid: EV_GRID
			-- Underlying EiffelVision-2 grid.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	column_titles: ARRAYED_LIST [STRING]
			-- Column header titles.

	row_data: ARRAYED_LIST [ARRAY [STRING]]
			-- Cached row data for sorting.

	column_count: INTEGER
			-- Number of columns.
		do
			Result := ev_grid.column_count
		end

	row_count: INTEGER
			-- Number of data rows (excluding header).
		do
			Result := ev_grid.row_count
		end

	is_empty: BOOLEAN
			-- Is grid empty?
		do
			Result := row_count = 0
		end

	selected_row: INTEGER
			-- Currently selected row (0 if none).
		do
			if ev_grid.selected_rows.count > 0 then
				Result := ev_grid.selected_rows.first.index
			end
		end

	has_selection: BOOLEAN
			-- Is a row selected?
		do
			Result := selected_row > 0
		end

	sort_column: INTEGER
			-- Currently sorted column (0 = none).

	sort_direction: INTEGER
			-- Current sort direction (Sort_none, Sort_ascending, Sort_descending).

	is_striped: BOOLEAN
			-- Is zebra striping enabled?

	cell_value (a_row, a_column: INTEGER): STRING
			-- Get cell value as string.
		require
			valid_row: a_row >= 1 and a_row <= row_count
			valid_column: a_column >= 1 and a_column <= column_count
		local
			l_item: detachable EV_GRID_ITEM
		do
			l_item := ev_grid.item (a_column, a_row)
			if attached {EV_GRID_LABEL_ITEM} l_item as lbl then
				Result := lbl.text.to_string_8
			else
				Result := ""
			end
		end

feature -- Configuration

	set_columns (a_columns: ARRAY [STRING])
			-- Set column headers.
		require
			columns_attached: a_columns /= Void
			columns_not_empty: not a_columns.is_empty
		local
			i: INTEGER
			l_col: EV_GRID_COLUMN
		do
			column_titles.wipe_out
			ev_grid.set_column_count_to (a_columns.count)
			from i := 1 until i > a_columns.count loop
				column_titles.extend (a_columns [i])
				l_col := ev_grid.column (i)
				l_col.set_title (a_columns [i])
				i := i + 1
			end
		end

	set_column_width (a_column, a_width: INTEGER)
			-- Set width of specific column.
		require
			valid_column: a_column >= 1 and a_column <= column_count
			positive_width: a_width > 0
		do
			ev_grid.column (a_column).set_width (a_width)
		end

	set_row_height (a_height: INTEGER)
			-- Set height of all rows.
		require
			positive_height: a_height > 0
		do
			ev_grid.set_row_height (a_height)
		end

	enable_single_row_selection
			-- Allow only single row selection.
		do
			ev_grid.enable_single_row_selection
		end

	enable_multiple_row_selection
			-- Allow multiple row selection.
		do
			ev_grid.enable_multiple_row_selection
		end

	show_header
			-- Show column headers.
		do
			ev_grid.show_header
		end

	hide_header
			-- Hide column headers.
		do
			ev_grid.hide_header
		end

feature -- Fluent Configuration

	columns (a_columns: ARRAY [STRING]): like Current
			-- Set columns (fluent).
		require
			columns_attached: a_columns /= Void
		do
			set_columns (a_columns)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	single_selection: like Current
			-- Enable single selection (fluent).
		do
			enable_single_row_selection
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	multi_selection: like Current
			-- Enable multiple selection (fluent).
		do
			enable_multiple_row_selection
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	header_visible (a_visible: BOOLEAN): like Current
			-- Set header visibility (fluent).
		do
			if a_visible then
				show_header
			else
				hide_header
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Data Management

	add_row (a_values: ARRAY [STRING])
			-- Add a row of data.
		require
			values_attached: a_values /= Void
			matching_columns: a_values.count = column_count
		local
			i: INTEGER
			l_row: EV_GRID_ROW
			l_item: EV_GRID_LABEL_ITEM
		do
			-- Cache for sorting
			row_data.extend (a_values)
			-- Add to grid
			ev_grid.insert_new_row (row_count + 1)
			l_row := ev_grid.row (row_count)
			from i := 1 until i > a_values.count loop
				create l_item.make_with_text (a_values [i])
				l_row.set_item (i, l_item)
				i := i + 1
			end
			-- Apply striping if enabled
			if is_striped then
				apply_row_colors
			end
		end

	set_cell (a_row, a_column: INTEGER; a_value: STRING)
			-- Set cell value.
		require
			valid_row: a_row >= 1 and a_row <= row_count
			valid_column: a_column >= 1 and a_column <= column_count
			value_attached: a_value /= Void
		local
			l_item: EV_GRID_LABEL_ITEM
		do
			create l_item.make_with_text (a_value)
			ev_grid.row (a_row).set_item (a_column, l_item)
		end

	rows (a_data: ARRAY [ARRAY [STRING]]): like Current
			-- Set all row data (fluent).
		require
			data_attached: a_data /= Void
		local
			i: INTEGER
		do
			clear_rows
			from i := a_data.lower until i > a_data.upper loop
				add_row (a_data [i])
				i := i + 1
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	select_row (a_row: INTEGER)
			-- Select a row.
		require
			valid_row: a_row >= 1 and a_row <= row_count
		do
			ev_grid.row (a_row).enable_select
		end

	deselect_all
			-- Clear selection.
		do
			ev_grid.remove_selection
		end

	clear_rows
			-- Remove all data rows.
		do
			ev_grid.set_row_count_to (0)
			row_data.wipe_out
			sort_column := 0
			sort_direction := Sort_none
		end

	clear
			-- Remove all rows and columns.
		do
			ev_grid.wipe_out
			column_titles.wipe_out
			row_data.wipe_out
			sort_column := 0
			sort_direction := Sort_none
		end

feature -- Events

	on_row_select (a_action: PROCEDURE)
			-- Call action when row is selected.
		require
			action_attached: a_action /= Void
		do
			ev_grid.row_select_actions.extend (agent (r: EV_GRID_ROW; act: PROCEDURE)
				do
					act.call (Void)
				end (?, a_action))
		end

	on_row_double_click (a_action: PROCEDURE)
			-- Call action when row is double-clicked.
		require
			action_attached: a_action /= Void
		do
			ev_grid.pointer_double_press_actions.extend (agent (x, y, b: INTEGER; x_t, y_t, p: REAL_64; sx, sy: INTEGER; act: PROCEDURE)
				do
					act.call (Void)
				end (?, ?, ?, ?, ?, ?, ?, ?, a_action))
		end

feature -- Sorting

	enable_sorting
			-- Enable clickable column headers for sorting.
		local
			i: INTEGER
			l_col: EV_GRID_COLUMN
		do
			from i := 1 until i > column_count loop
				l_col := ev_grid.column (i)
				l_col.header_item.pointer_button_press_actions.extend (agent on_header_click (i, ?, ?, ?, ?, ?, ?, ?, ?))
				i := i + 1
			end
		end

	sortable: like Current
			-- Enable sorting (fluent).
		do
			enable_sorting
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	sort_by_column (a_column: INTEGER; a_direction: INTEGER)
			-- Sort by specified column and direction.
		require
			valid_column: a_column >= 1 and a_column <= column_count
			valid_direction: a_direction >= Sort_none and a_direction <= Sort_descending
		do
			if a_direction = Sort_none then
				-- Restore natural order
				sort_column := 0
				sort_direction := Sort_none
			else
				sort_column := a_column
				sort_direction := a_direction
			end
			refresh_with_sort
			update_header_titles
		end

feature -- Striping

	enable_striping
			-- Enable zebra striping on rows.
		do
			is_striped := True
			apply_row_colors
		end

	disable_striping
			-- Disable zebra striping.
		do
			is_striped := False
			apply_row_colors
		end

	striped: like Current
			-- Enable striping (fluent).
		do
			enable_striping
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to grid.
		do
			ev_grid.set_background_color (tokens.surface.to_ev_color)
			ev_grid.set_foreground_color (tokens.text_primary.to_ev_color)
			apply_row_colors
		end

feature -- Sort Constants

	Sort_none: INTEGER = 0
			-- No sorting (natural order).

	Sort_ascending: INTEGER = 1
			-- Ascending sort order.

	Sort_descending: INTEGER = 2
			-- Descending sort order.

feature {NONE} -- Implementation

	on_header_click (a_column: INTEGER; x, y, button: INTEGER; x_tilt, y_tilt, pressure: REAL_64; sx, sy: INTEGER)
			-- Handle header click - cycle through sort states.
		do
			if sort_column = a_column then
				-- Cycle: None -> Asc -> Desc -> None
				inspect sort_direction
				when Sort_none then
					sort_by_column (a_column, Sort_ascending)
				when Sort_ascending then
					sort_by_column (a_column, Sort_descending)
				when Sort_descending then
					sort_by_column (a_column, Sort_none)
				end
			else
				-- New column: start with ascending
				sort_by_column (a_column, Sort_ascending)
			end
		end

	refresh_with_sort
			-- Redisplay data with current sort order.
		local
			l_sorted: ARRAYED_LIST [ARRAY [STRING]]
			i: INTEGER
		do
			if sort_direction = Sort_none or row_data.is_empty then
				-- Natural order - just redisplay
				l_sorted := row_data
			else
				l_sorted := sorted_data
			end
			-- Clear and repopulate grid
			ev_grid.set_row_count_to (0)
			from i := 1 until i > l_sorted.count loop
				add_row_internal (l_sorted [i])
				i := i + 1
			end
			apply_row_colors
		end

	sorted_data: ARRAYED_LIST [ARRAY [STRING]]
			-- Return row_data sorted by current column and direction.
		local
			l_result: ARRAYED_LIST [ARRAY [STRING]]
			l_sorter: SIMPLE_SORTER [ARRAY [STRING]]
			l_col: INTEGER
		do
			create l_result.make_from_iterable (row_data)
			l_col := sort_column
			create l_sorter.make
			if sort_direction = Sort_ascending then
				l_sorter.sort_by (l_result, agent row_column_key (?, l_col))
			else
				l_sorter.sort_by_descending (l_result, agent row_column_key (?, l_col))
			end
			Result := l_result
		end

	row_column_key (a_row: ARRAY [STRING]; a_col: INTEGER): STRING
			-- Extract column value for sorting.
		do
			Result := a_row [a_col]
		end

	add_row_internal (a_values: ARRAY [STRING])
			-- Add row without caching (used during sort refresh).
		local
			i: INTEGER
			l_row: EV_GRID_ROW
			l_item: EV_GRID_LABEL_ITEM
		do
			ev_grid.insert_new_row (ev_grid.row_count + 1)
			l_row := ev_grid.row (ev_grid.row_count)
			from i := 1 until i > a_values.count loop
				create l_item.make_with_text (a_values [i])
				l_row.set_item (i, l_item)
				i := i + 1
			end
		end

	update_header_titles
			-- Update column titles with sort indicators.
		local
			i: INTEGER
			l_title: STRING
		do
			from i := 1 until i > column_count loop
				l_title := column_titles [i].twin
				if i = sort_column then
					inspect sort_direction
					when Sort_ascending then
						l_title.append (" [ASC]")
					when Sort_descending then
						l_title.append (" [DESC]")
					else
						-- No indicator
					end
				end
				ev_grid.column (i).set_title (l_title)
				i := i + 1
			end
		end

	apply_row_colors
			-- Apply theme colors to all rows, with optional striping.
		local
			i, j: INTEGER
			l_row: EV_GRID_ROW
			l_bg: SV_COLOR
			l_item: detachable EV_GRID_ITEM
		do
			from i := 1 until i > ev_grid.row_count loop
				l_row := ev_grid.row (i)
				if is_striped and (i \\ 2 = 0) then
					l_bg := tokens.surface_variant
				else
					l_bg := tokens.surface
				end
				l_row.set_background_color (l_bg.to_ev_color)
				-- Apply to all cells in row
				from j := 1 until j > column_count loop
					l_item := ev_grid.item (j, i)
					if attached l_item then
						l_item.set_background_color (l_bg.to_ev_color)
						l_item.set_foreground_color (tokens.text_primary.to_ev_color)
					end
					j := j + 1
				end
				i := i + 1
			end
		end

invariant
	ev_grid_exists: ev_grid /= Void
	column_titles_exists: column_titles /= Void
	row_data_exists: row_data /= Void

end
