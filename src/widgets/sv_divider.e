note
	description: "Themed divider line - uses colored box instead of native separator"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_DIVIDER

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make_horizontal,
	make_vertical

feature {NONE} -- Initialization

	make_horizontal
			-- Create horizontal divider (thin line).
		do
			create ev_cell
			ev_cell.set_minimum_height (2)
			is_horizontal := True
			apply_theme
			subscribe_to_theme
		end

	make_vertical
			-- Create vertical divider (thin line).
		do
			create ev_cell
			ev_cell.set_minimum_width (2)
			is_horizontal := False
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_cell: EV_CELL
			-- Underlying colored cell.

	ev_widget: EV_WIDGET
			-- Widget for container operations.
		do
			Result := ev_cell
		end

	is_horizontal: BOOLEAN
			-- Is this a horizontal divider?

	is_vertical: BOOLEAN
			-- Is this a vertical divider?
		do
			Result := not is_horizontal
		end

feature -- Configuration

	thickness (a_pixels: INTEGER): like Current
			-- Set divider thickness.
		require
			positive: a_pixels > 0
		do
			if is_horizontal then
				ev_cell.set_minimum_height (a_pixels)
			else
				ev_cell.set_minimum_width (a_pixels)
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme divider color.
		do
			ev_cell.set_background_color (tokens.divider.to_ev_color)
		end

invariant
	ev_cell_exists: ev_cell /= Void

end
