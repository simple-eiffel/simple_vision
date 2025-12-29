note
	description: "[
		SV_WAVEFORM - Audio waveform visualization widget.

		Displays audio waveform data with customizable colors,
		background, and styling. Designed for Speech Studio
		and other audio applications.

		Usage:
			local
				waveform: SV_WAVEFORM
				samples: ARRAY [INTEGER_16]
			do
				create waveform.make (400, 100)
				waveform
					.set_waveform_color_hex (0x3498DB)
					.set_background_color_hex (0x2C3E50)
					.set_samples (samples)
					.redraw
			end

		Features:
		- INT16 PCM sample support (common audio format)
		- Float sample support (-1.0 to 1.0)
		- Customizable waveform and background colors
		- Center line option
		- Automatic scaling to fit widget
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_WAVEFORM

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make, make_default

feature {NONE} -- Initialization

	make (a_width, a_height: INTEGER)
			-- Create waveform widget with specified size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			widget_width := a_width
			widget_height := a_height

			-- Default colors
			waveform_color := 0x3498DB  -- Blue
			background_color := 0x2C3E50  -- Dark blue-gray
			center_line_color := 0x7F8C8D  -- Gray
			show_center_line := True
			line_width := 1.0

			create internal_drawing_area
			internal_drawing_area.set_minimum_size (a_width, a_height)
			internal_drawing_area.expose_actions.extend (agent on_expose)
			internal_drawing_area.resize_actions.extend (agent on_resize)

			create_surface
			needs_redraw := True
			subscribe_to_theme
		ensure
			width_set: widget_width = a_width
			height_set: widget_height = a_height
		end

	make_default
			-- Create with default size.
		do
			make (200, 60)
		end

feature -- Access

	ev_widget: EV_WIDGET
			-- Underlying EiffelVision widget.
		do
			Result := internal_drawing_area
		end

	widget_width: INTEGER
			-- Widget width in pixels.

	widget_height: INTEGER
			-- Widget height in pixels.

	sample_count: INTEGER
			-- Number of samples currently loaded.

feature -- Sample Data

	set_samples_i16 (a_samples: ARRAY [INTEGER_16]): like Current
			-- Set waveform data from int16 PCM samples.
		require
			samples_not_empty: not a_samples.is_empty
		do
			create samples_i16.make_from_array (a_samples)
			samples_float := Void
			sample_count := a_samples.count
			render_waveform
			Result := Current
		ensure
			samples_set: sample_count = a_samples.count
		end

	set_samples_float (a_samples: ARRAY [REAL_32]): like Current
			-- Set waveform data from float samples (-1.0 to 1.0).
		require
			samples_not_empty: not a_samples.is_empty
		do
			create samples_float.make_from_array (a_samples)
			samples_i16 := Void
			sample_count := a_samples.count
			render_waveform
			Result := Current
		ensure
			samples_set: sample_count = a_samples.count
		end

	clear_samples: like Current
			-- Clear waveform data.
		do
			samples_i16 := Void
			samples_float := Void
			sample_count := 0
			render_waveform
			Result := Current
		ensure
			cleared: sample_count = 0
		end

feature -- Colors (Fluent API)

	set_waveform_color_hex (a_color: NATURAL_32): like Current
			-- Set waveform color from hex.
		do
			waveform_color := a_color
			needs_redraw := True
			Result := Current
		end

	set_waveform_color_rgb (a_r, a_g, a_b: INTEGER): like Current
			-- Set waveform color from RGB (0-255).
		require
			valid_r: a_r >= 0 and a_r <= 255
			valid_g: a_g >= 0 and a_g <= 255
			valid_b: a_b >= 0 and a_b <= 255
		do
			waveform_color := ((a_r |<< 16) | (a_g |<< 8) | a_b).to_natural_32
			needs_redraw := True
			Result := Current
		end

	set_background_color_hex (a_color: NATURAL_32): like Current
			-- Set background color from hex.
		do
			background_color := a_color
			needs_redraw := True
			Result := Current
		end

	set_background_color_rgb (a_r, a_g, a_b: INTEGER): like Current
			-- Set background color from RGB (0-255).
		require
			valid_r: a_r >= 0 and a_r <= 255
			valid_g: a_g >= 0 and a_g <= 255
			valid_b: a_b >= 0 and a_b <= 255
		do
			background_color := ((a_r |<< 16) | (a_g |<< 8) | a_b).to_natural_32
			needs_redraw := True
			Result := Current
		end

	set_center_line_color_hex (a_color: NATURAL_32): like Current
			-- Set center line color from hex.
		do
			center_line_color := a_color
			needs_redraw := True
			Result := Current
		end

feature -- Options (Fluent API)

	enable_center_line: like Current
			-- Show center line.
		do
			show_center_line := True
			needs_redraw := True
			Result := Current
		end

	disable_center_line: like Current
			-- Hide center line.
		do
			show_center_line := False
			needs_redraw := True
			Result := Current
		end

	center_line (a_show: BOOLEAN): like Current
			-- Set center line visibility.
		do
			show_center_line := a_show
			needs_redraw := True
			Result := Current
		end

	set_line_width (a_width: REAL_64): like Current
			-- Set waveform line width.
		require
			positive: a_width > 0
		do
			line_width := a_width
			needs_redraw := True
			Result := Current
		end

feature -- Display

	redraw: like Current
			-- Force redraw.
		do
			if needs_redraw then
				render_waveform
			end
			internal_drawing_area.redraw
			Result := Current
		end

	invalidate: like Current
			-- Mark as needing redraw.
		do
			needs_redraw := True
			internal_drawing_area.redraw
			Result := Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors.
		do
			-- Use theme colors if not explicitly set
			-- (keep existing colors for now - waveform often has custom colors)
			internal_drawing_area.set_background_color (color_from_hex (background_color))
		end

feature -- Resize

	resize (a_width, a_height: INTEGER): like Current
			-- Resize widget.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			if a_width /= widget_width or a_height /= widget_height then
				widget_width := a_width
				widget_height := a_height
				internal_drawing_area.set_minimum_size (a_width, a_height)
				destroy_surface
				create_surface
				render_waveform
			end
			Result := Current
		end

feature -- Cleanup

	destroy
			-- Release resources.
		do
			destroy_surface
		end

feature {NONE} -- Implementation

	internal_drawing_area: EV_DRAWING_AREA
			-- Underlying drawing area.

	surface: detachable CAIRO_SURFACE
			-- Cairo surface.

	context: detachable CAIRO_CONTEXT
			-- Cairo context.

	samples_i16: detachable ARRAYED_LIST [INTEGER_16]
			-- INT16 PCM samples.

	samples_float: detachable ARRAYED_LIST [REAL_32]
			-- Float samples (-1.0 to 1.0).

	waveform_color: NATURAL_32
			-- Waveform line color.

	background_color: NATURAL_32
			-- Background color.

	center_line_color: NATURAL_32
			-- Center line color.

	show_center_line: BOOLEAN
			-- Show center line?

	line_width: REAL_64
			-- Waveform line width.

	needs_redraw: BOOLEAN
			-- Needs redraw?

	create_surface
			-- Create Cairo surface.
		local
			l_cairo: SIMPLE_CAIRO
		do
			create l_cairo.make
			surface := l_cairo.create_surface (widget_width, widget_height)
			if attached surface as s and then s.is_valid then
				context := l_cairo.create_context (s)
			end
		end

	destroy_surface
			-- Release Cairo resources.
		do
			if attached context as ctx then
				ctx.destroy
				context := Void
			end
			if attached surface as s then
				s.destroy
				surface := Void
			end
		end

	render_waveform
			-- Render waveform to Cairo surface.
		local
			l_mid_y: REAL_64
			l_samples_per_pixel: REAL_64
			l_px: INTEGER
			l_start_sample, l_end_sample: INTEGER
			l_min_val, l_max_val: REAL_64
			l_sample: REAL_64
			l_y_min, l_y_max: REAL_64
			l_i: INTEGER
		do
			if attached context as ctx then
				-- Clear background
				ctx.set_color_hex (background_color).paint.do_nothing

				-- Draw center line
				if show_center_line then
					l_mid_y := widget_height / 2.0
					ctx.set_color_hex (center_line_color)
					   .set_line_width (1.0)
					   .draw_line (0, l_mid_y, widget_width, l_mid_y).do_nothing
				end

				-- Draw waveform
				if sample_count > 0 then
					l_mid_y := widget_height / 2.0
					l_samples_per_pixel := sample_count / widget_width

					ctx.set_color_hex (waveform_color)
					   .set_line_width (line_width).do_nothing

					from l_px := 0 until l_px >= widget_width loop
						l_start_sample := (l_px * l_samples_per_pixel).truncated_to_integer + 1
						l_end_sample := ((l_px + 1) * l_samples_per_pixel).truncated_to_integer + 1
						l_end_sample := l_end_sample.min (sample_count)

						-- Find min/max in this pixel's range
						l_min_val := 0
						l_max_val := 0

						if attached samples_i16 as s16 then
							from l_i := l_start_sample until l_i > l_end_sample loop
								if l_i <= s16.count then
									l_sample := s16 [l_i] / 32768.0
									if l_sample < l_min_val then l_min_val := l_sample end
									if l_sample > l_max_val then l_max_val := l_sample end
								end
								l_i := l_i + 1
							end
						elseif attached samples_float as sf then
							from l_i := l_start_sample until l_i > l_end_sample loop
								if l_i <= sf.count then
									l_sample := sf [l_i]
									if l_sample < l_min_val then l_min_val := l_sample end
									if l_sample > l_max_val then l_max_val := l_sample end
								end
								l_i := l_i + 1
							end
						end

						-- Draw vertical line for this pixel
						l_y_min := l_mid_y - (l_max_val * widget_height / 2.0)
						l_y_max := l_mid_y - (l_min_val * widget_height / 2.0)

						ctx.draw_line (l_px, l_y_min, l_px, l_y_max).do_nothing

						l_px := l_px + 1
					end
				end

				needs_redraw := False
				copy_surface_to_drawing_area
			end
		end

	copy_surface_to_drawing_area
			-- Copy Cairo surface to drawing area.
		local
			l_data: POINTER
			l_stride: INTEGER
			l_row, l_col: INTEGER
			l_offset: INTEGER
			l_r, l_g, l_b: NATURAL_8
			l_managed: MANAGED_POINTER
			l_color: EV_COLOR
		do
			if attached surface as s and then s.is_valid then
				l_data := s.data
				l_stride := s.stride

				create l_managed.share_from_pointer (l_data, widget_height * l_stride)

				from l_row := 0 until l_row >= widget_height loop
					from l_col := 0 until l_col >= widget_width loop
						l_offset := l_row * l_stride + l_col * 4
						-- Cairo ARGB32 is BGRA on little-endian
						l_b := l_managed.read_natural_8 (l_offset)
						l_g := l_managed.read_natural_8 (l_offset + 1)
						l_r := l_managed.read_natural_8 (l_offset + 2)
						create l_color.make_with_8_bit_rgb (l_r, l_g, l_b)
						internal_drawing_area.set_foreground_color (l_color)
						internal_drawing_area.draw_point (l_col, l_row)
						l_col := l_col + 1
					end
					l_row := l_row + 1
				end
			end
		end

	color_from_hex (a_hex: NATURAL_32): EV_COLOR
			-- Convert hex color to EV_COLOR.
		local
			l_r, l_g, l_b: INTEGER
		do
			l_r := ((a_hex |>> 16) & 0xFF).to_integer_32
			l_g := ((a_hex |>> 8) & 0xFF).to_integer_32
			l_b := (a_hex & 0xFF).to_integer_32
			create Result.make_with_8_bit_rgb (l_r, l_g, l_b)
		end

	on_expose (a_x, a_y, a_width, a_height: INTEGER)
			-- Handle expose event.
		do
			copy_surface_to_drawing_area
		end

	on_resize (a_x, a_y, a_width, a_height: INTEGER)
			-- Handle resize event.
		do
			if a_width > 0 and a_height > 0 then
				if a_width /= widget_width or a_height /= widget_height then
					widget_width := a_width
					widget_height := a_height
					destroy_surface
					create_surface
					render_waveform
				end
			end
		end

invariant
	drawing_area_attached: internal_drawing_area /= Void
	positive_width: widget_width > 0
	positive_height: widget_height > 0

end
