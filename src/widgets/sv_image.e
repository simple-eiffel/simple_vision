note
	description: "Image display widget - wraps EV_PIXMAP"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_IMAGE

inherit
	SV_WIDGET
		rename
			width as set_width_fluent,
			height as set_height_fluent
		end

create
	make,
	make_from_file,
	make_sized

feature {NONE} -- Initialization

	make
			-- Create empty image widget.
		do
			create ev_pixmap
			ev_widget := ev_pixmap
		end

	make_from_file (a_path: READABLE_STRING_GENERAL)
			-- Create image from file.
		require
			path_not_empty: not a_path.is_empty
		do
			make
			load_from_file (a_path)
		end

	make_sized (a_width, a_height: INTEGER)
			-- Create blank image of specified size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			make
			ev_pixmap.set_size (a_width, a_height)
		end

feature -- Access

	ev_pixmap: EV_PIXMAP
			-- Underlying EiffelVision-2 pixmap.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	width: INTEGER
			-- Image width.
		do
			Result := ev_pixmap.width
		end

	height: INTEGER
			-- Image height.
		do
			Result := ev_pixmap.height
		end

	is_loaded: BOOLEAN
			-- Has an image been loaded?
		do
			Result := width > 0 and height > 0
		end

	file_path: detachable STRING
			-- Path to loaded image file (if any).

feature -- File Operations

	load_from_file (a_path: READABLE_STRING_GENERAL)
			-- Load image from file.
		require
			path_not_empty: not a_path.is_empty
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				ev_pixmap.set_with_named_file (a_path.to_string_8)
				file_path := a_path.to_string_8
			end
		rescue
			l_retried := True
			retry
		end

	save_to_file (a_path: READABLE_STRING_GENERAL)
			-- Save image to file.
		require
			path_not_empty: not a_path.is_empty
			is_loaded: is_loaded
		do
			ev_pixmap.save_to_named_file (create {EV_PNG_FORMAT}, a_path.to_string_8)
		end

feature -- Configuration

	set_size (a_width, a_height: INTEGER)
			-- Set image size (stretches if loaded).
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			ev_pixmap.set_size (a_width, a_height)
		end

	stretch_to (a_width, a_height: INTEGER)
			-- Stretch image to new dimensions.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			ev_pixmap.stretch (a_width, a_height)
		end

feature -- Fluent Configuration

	from_file (a_path: READABLE_STRING_GENERAL): like Current
			-- Load from file (fluent).
		require
			path_not_empty: not a_path.is_empty
		do
			load_from_file (a_path)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	sized (a_width, a_height: INTEGER): like Current
			-- Set size (fluent).
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			set_size (a_width, a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	stretched (a_width, a_height: INTEGER): like Current
			-- Stretch to size (fluent).
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			stretch_to (a_width, a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Drawing

	clear
			-- Clear the image (fill with white).
		do
			ev_pixmap.clear
		end

	fill_color (a_red, a_green, a_blue: INTEGER)
			-- Fill with solid color.
		require
			valid_red: a_red >= 0 and a_red <= 255
			valid_green: a_green >= 0 and a_green <= 255
			valid_blue: a_blue >= 0 and a_blue <= 255
		local
			l_color: EV_COLOR
		do
			create l_color.make_with_8_bit_rgb (a_red, a_green, a_blue)
			ev_pixmap.set_foreground_color (l_color)
			ev_pixmap.fill_rectangle (0, 0, width, height)
		end

invariant
	ev_pixmap_exists: ev_pixmap /= Void

end
