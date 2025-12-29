note
	description: "Color picker dialog - wraps EV_COLOR_DIALOG"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_COLOR_PICKER

inherit
	SV_ANY

create
	make,
	make_with_color

feature {NONE} -- Initialization

	make
			-- Create color picker with default color (black).
		do
			create ev_color_dialog
			create selected_color.make_with_8_bit_rgb (0, 0, 0)
		end

	make_with_color (a_color: EV_COLOR)
			-- Create color picker with initial color.
		require
			color_attached: a_color /= Void
		do
			create ev_color_dialog
			ev_color_dialog.set_color (a_color)
			selected_color := a_color.twin
		end

feature -- Access

	ev_color_dialog: EV_COLOR_DIALOG
			-- Underlying EiffelVision-2 color dialog.

	selected_color: EV_COLOR
			-- Currently selected color.

	red: INTEGER
			-- Red component (0-255).
		do
			Result := selected_color.red_8_bit
		end

	green: INTEGER
			-- Green component (0-255).
		do
			Result := selected_color.green_8_bit
		end

	blue: INTEGER
			-- Blue component (0-255).
		do
			Result := selected_color.blue_8_bit
		end

	rgb_string: STRING
			-- Color as RGB string "R,G,B".
		do
			Result := red.out + "," + green.out + "," + blue.out
		end

	hex_string: STRING
			-- Color as hex string "#RRGGBB".
		do
			Result := "#" +
				red.to_hex_string.substring (7, 8) +
				green.to_hex_string.substring (7, 8) +
				blue.to_hex_string.substring (7, 8)
		end

	was_selected: BOOLEAN
			-- Was a color selected (not cancelled)?

feature -- Configuration

	set_title (a_title: STRING)
			-- Set dialog title.
		require
			title_not_empty: not a_title.is_empty
		do
			ev_color_dialog.set_title (a_title)
		end

	title (a_title: STRING): like Current
			-- Set title (fluent).
		require
			title_not_empty: not a_title.is_empty
		do
			set_title (a_title)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_color (a_color: EV_COLOR)
			-- Set initial color.
		require
			color_attached: a_color /= Void
		do
			ev_color_dialog.set_color (a_color)
			selected_color := a_color.twin
		end

	set_rgb (a_red, a_green, a_blue: INTEGER)
			-- Set initial color by RGB values.
		require
			valid_red: a_red >= 0 and a_red <= 255
			valid_green: a_green >= 0 and a_green <= 255
			valid_blue: a_blue >= 0 and a_blue <= 255
		do
			create selected_color.make_with_8_bit_rgb (a_red, a_green, a_blue)
			ev_color_dialog.set_color (selected_color)
		end

	initial_color (a_red, a_green, a_blue: INTEGER): like Current
			-- Set initial color (fluent).
		require
			valid_red: a_red >= 0 and a_red <= 255
			valid_green: a_green >= 0 and a_green <= 255
			valid_blue: a_blue >= 0 and a_blue <= 255
		do
			set_rgb (a_red, a_green, a_blue)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Display

	show (a_parent: SV_WINDOW)
			-- Show color picker modal to parent.
		require
			parent_attached: a_parent /= Void
		local
			l_old_color: EV_COLOR
		do
			l_old_color := selected_color.twin
			ev_color_dialog.show_modal_to_window (a_parent.ev_titled_window)
			selected_color := ev_color_dialog.color
			was_selected := not selected_color.is_equal (l_old_color)
		end

	show_and_get_color (a_parent: SV_WINDOW): EV_COLOR
			-- Show picker and return selected color.
		require
			parent_attached: a_parent /= Void
		do
			show (a_parent)
			Result := selected_color
		end

feature -- Predefined Colors

	set_black
			-- Set to black.
		do
			set_rgb (0, 0, 0)
		end

	set_white
			-- Set to white.
		do
			set_rgb (255, 255, 255)
		end

	set_red
			-- Set to red.
		do
			set_rgb (255, 0, 0)
		end

	set_green
			-- Set to green.
		do
			set_rgb (0, 255, 0)
		end

	set_blue
			-- Set to blue.
		do
			set_rgb (0, 0, 255)
		end

invariant
	ev_color_dialog_exists: ev_color_dialog /= Void
	selected_color_exists: selected_color /= Void

end
