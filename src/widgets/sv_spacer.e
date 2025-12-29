note
	description: "Flexible spacer widget for layouts"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SPACER

inherit
	SV_WIDGET
		rename
			width as set_width_fluent,
			height as set_height_fluent
		redefine
			apply_theme
		end

create
	make,
	make_fixed

feature {NONE} -- Initialization

	make
			-- Create flexible spacer (expands to fill space).
		do
			create ev_cell
			ev_widget := ev_cell
			is_flexible := True
			apply_theme
			subscribe_to_theme
		end

	make_fixed (a_size: INTEGER)
			-- Create fixed-size spacer.
		require
			positive_size: a_size > 0
		do
			make
			ev_cell.set_minimum_size (a_size, a_size)
			is_flexible := False
			fixed_size := a_size
		end

feature -- Access

	ev_cell: EV_CELL
			-- Underlying EiffelVision-2 cell (empty container).

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	is_flexible: BOOLEAN
			-- Does spacer expand to fill available space?

	is_fixed: BOOLEAN
			-- Is spacer fixed size?
		do
			Result := not is_flexible
		end

	fixed_size: INTEGER
			-- Size in pixels (if fixed).

feature -- Configuration

	set_fixed_size (a_size: INTEGER)
			-- Set fixed size.
		require
			positive_size: a_size > 0
		do
			ev_cell.set_minimum_size (a_size, a_size)
			is_flexible := False
			fixed_size := a_size
		end

	set_width (a_width: INTEGER)
			-- Set minimum width (for horizontal spacer in vbox).
		require
			positive: a_width > 0
		do
			ev_cell.set_minimum_width (a_width)
		end

	set_height (a_height: INTEGER)
			-- Set minimum height (for vertical spacer in hbox).
		require
			positive: a_height > 0
		do
			ev_cell.set_minimum_height (a_height)
		end

feature -- Fluent Configuration

	fixed (a_size: INTEGER): like Current
			-- Set fixed size (fluent).
		require
			positive_size: a_size > 0
		do
			set_fixed_size (a_size)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	width (a_width: INTEGER): like Current
			-- Set width (fluent).
		require
			positive: a_width > 0
		do
			set_width (a_width)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	height (a_height: INTEGER): like Current
			-- Set height (fluent).
		require
			positive: a_height > 0
		do
			set_height (a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to spacer (make it blend with background).
		do
			ev_cell.set_background_color (tokens.background.to_ev_color)
		end

invariant
	ev_cell_exists: ev_cell /= Void

end
