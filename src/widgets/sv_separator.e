note
	description: "Separator line widget - wraps EV_HORIZONTAL_SEPARATOR and EV_VERTICAL_SEPARATOR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SEPARATOR

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
			-- Create horizontal separator line.
		local
			l_sep: EV_HORIZONTAL_SEPARATOR
		do
			create l_sep
			ev_widget := l_sep
			is_horizontal := True
			apply_theme
			subscribe_to_theme
		end

	make_vertical
			-- Create vertical separator line.
		local
			l_sep: EV_VERTICAL_SEPARATOR
		do
			create l_sep
			ev_widget := l_sep
			is_horizontal := False
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	is_horizontal: BOOLEAN
			-- Is this a horizontal separator?

	is_vertical: BOOLEAN
			-- Is this a vertical separator?
		do
			Result := not is_horizontal
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to separator.
		do
			ev_widget.set_background_color (tokens.divider.to_ev_color)
		end

end
