note
	description: "Grid layout container - wraps EV_TABLE"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_GRID

inherit
	SV_WIDGET

create
	make,
	make_sized

feature {NONE} -- Initialization

	make
			-- Create empty grid.
		do
			create ev_table
			ev_widget := ev_table
			column_count := 1
			row_count := 1
		end

	make_sized (a_columns, a_rows: INTEGER)
			-- Create grid with specified dimensions.
		require
			valid_columns: a_columns > 0
			valid_rows: a_rows > 0
		do
			make
			column_count := a_columns
			row_count := a_rows
			ev_table.resize (a_columns, a_rows)
		end

feature -- Access

	ev_table: EV_TABLE
			-- Underlying EiffelVision-2 table.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	column_count: INTEGER
			-- Number of columns.

	row_count: INTEGER
			-- Number of rows.

feature -- Configuration

	set_columns (a_count: INTEGER)
			-- Set number of columns.
		require
			valid_count: a_count > 0
		do
			column_count := a_count
			ev_table.resize (column_count, row_count)
		end

	set_rows (a_count: INTEGER)
			-- Set number of rows.
		require
			valid_count: a_count > 0
		do
			row_count := a_count
			ev_table.resize (column_count, row_count)
		end

	set_row_spacing (a_spacing: INTEGER)
			-- Set vertical spacing between rows.
		require
			non_negative: a_spacing >= 0
		do
			ev_table.set_row_spacing (a_spacing)
		end

	set_column_spacing (a_spacing: INTEGER)
			-- Set horizontal spacing between columns.
		require
			non_negative: a_spacing >= 0
		do
			ev_table.set_column_spacing (a_spacing)
		end

	set_spacing (a_spacing: INTEGER)
			-- Set uniform spacing.
		require
			non_negative: a_spacing >= 0
		do
			ev_table.set_row_spacing (a_spacing)
			ev_table.set_column_spacing (a_spacing)
		end

	set_border (a_width: INTEGER)
			-- Set border width.
		require
			non_negative: a_width >= 0
		do
			ev_table.set_border_width (a_width)
		end

feature -- Fluent Configuration

	columns (a_count: INTEGER): like Current
			-- Set columns (fluent).
		require
			valid_count: a_count > 0
		do
			set_columns (a_count)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	rows (a_count: INTEGER): like Current
			-- Set rows (fluent).
		require
			valid_count: a_count > 0
		do
			set_rows (a_count)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	gap (a_spacing: INTEGER): like Current
			-- Set uniform gap (fluent).
		require
			non_negative: a_spacing >= 0
		do
			set_spacing (a_spacing)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	row_gap (a_spacing: INTEGER): like Current
			-- Set row gap (fluent).
		require
			non_negative: a_spacing >= 0
		do
			set_row_spacing (a_spacing)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	column_gap (a_spacing: INTEGER): like Current
			-- Set column gap (fluent).
		require
			non_negative: a_spacing >= 0
		do
			set_column_spacing (a_spacing)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	border (a_width: INTEGER): like Current
			-- Set border (fluent).
		require
			non_negative: a_width >= 0
		do
			set_border (a_width)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Adding Widgets

	add_at (a_widget: SV_WIDGET; a_column, a_row: INTEGER)
			-- Add widget at specified position (1-based).
		require
			widget_attached: a_widget /= Void
			valid_column: a_column >= 1 and a_column <= column_count
			valid_row: a_row >= 1 and a_row <= row_count
		do
			ev_table.put_at_position (a_widget.ev_widget, a_column, a_row, 1, 1)
		end

	add_spanning (a_widget: SV_WIDGET; a_column, a_row, a_col_span, a_row_span: INTEGER)
			-- Add widget spanning multiple cells.
		require
			widget_attached: a_widget /= Void
			valid_column: a_column >= 1 and a_column <= column_count
			valid_row: a_row >= 1 and a_row <= row_count
			valid_col_span: a_col_span >= 1 and a_column + a_col_span - 1 <= column_count
			valid_row_span: a_row_span >= 1 and a_row + a_row_span - 1 <= row_count
		do
			ev_table.put_at_position (a_widget.ev_widget, a_column, a_row, a_col_span, a_row_span)
		end

	put (a_widget: SV_WIDGET; a_column, a_row: INTEGER): like Current
			-- Add widget at position (fluent).
		require
			widget_attached: a_widget /= Void
			valid_column: a_column >= 1 and a_column <= column_count
			valid_row: a_row >= 1 and a_row <= row_count
		do
			add_at (a_widget, a_column, a_row)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	ev_table_exists: ev_table /= Void
	valid_dimensions: column_count >= 1 and row_count >= 1

end
