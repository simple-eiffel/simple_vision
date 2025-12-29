note
	description: "[
		SV_CAIRO_CANVAS - Cairo-powered drawing canvas for simple_vision.

		Bridges Cairo 2D graphics to EiffelVision windows. Provides
		high-quality vector graphics, gradients, and custom drawing.

		Usage:
			local
				canvas: SV_CAIRO_CANVAS
			do
				create canvas.make (400, 300)
				canvas
					.clear_hex (0xFFFFFF)
					.set_color_hex (0x3498DB)
					.fill_rect (10, 10, 100, 50)
					.set_color_hex (0xE74C3C)
					.set_line_width (3.0)
					.stroke_circle (200, 150, 50)
					.redraw.do_nothing

				-- Add to window
				window.extend (canvas)
			end

		For waveforms, use the specialized SV_WAVEFORM widget.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_CAIRO_CANVAS

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make, make_empty

feature {NONE} -- Initialization

	make (a_width, a_height: INTEGER)
			-- Create canvas with specified size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			canvas_width := a_width
			canvas_height := a_height
			create internal_drawing_area
			internal_drawing_area.set_minimum_size (a_width, a_height)
			internal_drawing_area.expose_actions.extend (agent on_expose)
			internal_drawing_area.resize_actions.extend (agent on_resize)
			create_surface
			needs_redraw := True
			subscribe_to_theme
		ensure
			width_set: canvas_width = a_width
			height_set: canvas_height = a_height
		end

	make_empty
			-- Create with default size (will resize on first display).
		do
			make (100, 100)
		end

feature -- Access

	ev_widget: EV_WIDGET
			-- Underlying EiffelVision widget.
		do
			Result := internal_drawing_area
		end

	drawing_area: EV_DRAWING_AREA
			-- Direct access to drawing area.
		do
			Result := internal_drawing_area
		end

	canvas_width: INTEGER
			-- Canvas width in pixels.

	canvas_height: INTEGER
			-- Canvas height in pixels.

	context: detachable CAIRO_CONTEXT
			-- Current Cairo drawing context.
			-- Available after surface creation.

feature -- Drawing: Color (Fluent API)

	set_color_rgb (a_r, a_g, a_b: REAL_64): like Current
			-- Set drawing color from RGB (0.0-1.0).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_rgb (a_r, a_g, a_b).do_nothing
			end
			Result := Current
		end

	set_color_rgba (a_r, a_g, a_b, a_a: REAL_64): like Current
			-- Set drawing color from RGBA (0.0-1.0).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_rgba (a_r, a_g, a_b, a_a).do_nothing
			end
			Result := Current
		end

	set_color_hex (a_hex: NATURAL_32): like Current
			-- Set drawing color from hex (0xRRGGBB).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_hex (a_hex).do_nothing
			end
			Result := Current
		end

	set_color_hex_alpha (a_hex: NATURAL_32): like Current
			-- Set drawing color from hex with alpha (0xAARRGGBB).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_hex_alpha (a_hex).do_nothing
			end
			Result := Current
		end

feature -- Drawing: Line Properties (Fluent API)

	set_line_width (a_width: REAL_64): like Current
			-- Set line width for strokes.
		require
			has_context: context /= Void
			positive: a_width > 0
		do
			if attached context as ctx then
				ctx.set_line_width (a_width).do_nothing
			end
			Result := Current
		end

feature -- Drawing: Shapes (Fluent API)

	fill_rect (a_x, a_y, a_w, a_h: REAL_64): like Current
			-- Draw filled rectangle.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.fill_rect (a_x, a_y, a_w, a_h).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	stroke_rect (a_x, a_y, a_w, a_h: REAL_64): like Current
			-- Draw rectangle outline.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.stroke_rect (a_x, a_y, a_w, a_h).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	fill_circle (a_cx, a_cy, a_radius: REAL_64): like Current
			-- Draw filled circle.
		require
			has_context: context /= Void
			positive_radius: a_radius > 0
		do
			if attached context as ctx then
				ctx.fill_circle (a_cx, a_cy, a_radius).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	stroke_circle (a_cx, a_cy, a_radius: REAL_64): like Current
			-- Draw circle outline.
		require
			has_context: context /= Void
			positive_radius: a_radius > 0
		do
			if attached context as ctx then
				ctx.stroke_circle (a_cx, a_cy, a_radius).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	draw_line (a_x1, a_y1, a_x2, a_y2: REAL_64): like Current
			-- Draw a line.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.draw_line (a_x1, a_y1, a_x2, a_y2).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	rounded_rect (a_x, a_y, a_w, a_h, a_radius: REAL_64): like Current
			-- Add rounded rectangle to path.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.rounded_rectangle (a_x, a_y, a_w, a_h, a_radius).do_nothing
			end
			Result := Current
		end

feature -- Drawing: Path Operations (Fluent API)

	move_to (a_x, a_y: REAL_64): like Current
			-- Move to position (start new sub-path).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.move_to (a_x, a_y).do_nothing
			end
			Result := Current
		end

	line_to (a_x, a_y: REAL_64): like Current
			-- Draw line to position.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.line_to (a_x, a_y).do_nothing
			end
			Result := Current
		end

	curve_to (a_x1, a_y1, a_x2, a_y2, a_x3, a_y3: REAL_64): like Current
			-- Draw cubic Bezier curve.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.curve_to (a_x1, a_y1, a_x2, a_y2, a_x3, a_y3).do_nothing
			end
			Result := Current
		end

	arc (a_xc, a_yc, a_radius, a_angle1, a_angle2: REAL_64): like Current
			-- Draw arc (angles in radians).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.arc (a_xc, a_yc, a_radius, a_angle1, a_angle2).do_nothing
			end
			Result := Current
		end

	close_path: like Current
			-- Close current path.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.close_path.do_nothing
			end
			Result := Current
		end

	stroke: like Current
			-- Stroke current path.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.stroke.do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	fill: like Current
			-- Fill current path.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.fill.do_nothing
			end
			needs_redraw := True
			Result := Current
		end

feature -- Drawing: Clear

	clear_rgb (a_r, a_g, a_b: REAL_64): like Current
			-- Clear canvas to specified color.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_rgb (a_r, a_g, a_b).paint.do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	clear_hex (a_hex: NATURAL_32): like Current
			-- Clear canvas to hex color.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.set_color_hex (a_hex).paint.do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	clear: like Current
			-- Clear canvas to transparent.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.clear.do_nothing
			end
			needs_redraw := True
			Result := Current
		end

feature -- Drawing: Gradients

	fill_gradient (a_gradient: CAIRO_GRADIENT; a_x, a_y, a_w, a_h: REAL_64): like Current
			-- Fill rectangle with gradient.
		require
			has_context: context /= Void
			gradient_valid: a_gradient.is_valid
		do
			if attached context as ctx then
				ctx.set_gradient (a_gradient).fill_rect (a_x, a_y, a_w, a_h).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

	fill_gradient_vertical (a_top_color, a_bottom_color: NATURAL_32; a_x, a_y, a_w, a_h: REAL_64): like Current
			-- Fill rectangle with vertical gradient.
		require
			has_context: context /= Void
		local
			l_grad: CAIRO_GRADIENT
		do
			create l_grad.make_linear (0, a_y, 0, a_y + a_h)
			l_grad.add_stop_hex (0.0, a_top_color).add_stop_hex (1.0, a_bottom_color).do_nothing
			if attached context as ctx then
				ctx.set_gradient (l_grad).fill_rect (a_x, a_y, a_w, a_h).do_nothing
			end
			l_grad.destroy
			needs_redraw := True
			Result := Current
		end

	fill_gradient_horizontal (a_left_color, a_right_color: NATURAL_32; a_x, a_y, a_w, a_h: REAL_64): like Current
			-- Fill rectangle with horizontal gradient.
		require
			has_context: context /= Void
		local
			l_grad: CAIRO_GRADIENT
		do
			create l_grad.make_linear (a_x, 0, a_x + a_w, 0)
			l_grad.add_stop_hex (0.0, a_left_color).add_stop_hex (1.0, a_right_color).do_nothing
			if attached context as ctx then
				ctx.set_gradient (l_grad).fill_rect (a_x, a_y, a_w, a_h).do_nothing
			end
			l_grad.destroy
			needs_redraw := True
			Result := Current
		end

feature -- Drawing: Text

	set_font (a_family: STRING; a_size: REAL_64): like Current
			-- Set font for text drawing.
		require
			has_context: context /= Void
			family_not_empty: not a_family.is_empty
			positive_size: a_size > 0
		do
			if attached context as ctx then
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_normal)
				   .set_font_size (a_size).do_nothing
			end
			Result := Current
		end

	set_font_bold (a_family: STRING; a_size: REAL_64): like Current
			-- Set bold font for text drawing.
		require
			has_context: context /= Void
			family_not_empty: not a_family.is_empty
			positive_size: a_size > 0
		do
			if attached context as ctx then
				ctx.select_font (a_family, ctx.Slant_normal, ctx.Weight_bold)
				   .set_font_size (a_size).do_nothing
			end
			Result := Current
		end

	draw_text (a_x, a_y: REAL_64; a_text: STRING): like Current
			-- Draw text at position.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.move_to (a_x, a_y).show_text (a_text).do_nothing
			end
			needs_redraw := True
			Result := Current
		end

feature -- Drawing: Transforms

	translate (a_tx, a_ty: REAL_64): like Current
			-- Translate coordinate system.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.translate (a_tx, a_ty).do_nothing
			end
			Result := Current
		end

	scale (a_sx, a_sy: REAL_64): like Current
			-- Scale coordinate system.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.scale (a_sx, a_sy).do_nothing
			end
			Result := Current
		end

	rotate (a_angle: REAL_64): like Current
			-- Rotate coordinate system (radians).
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.rotate (a_angle).do_nothing
			end
			Result := Current
		end

	save_state: like Current
			-- Save current drawing state.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.save.do_nothing
			end
			Result := Current
		end

	restore_state: like Current
			-- Restore saved drawing state.
		require
			has_context: context /= Void
		do
			if attached context as ctx then
				ctx.restore.do_nothing
			end
			Result := Current
		end

feature -- Display

	redraw: like Current
			-- Force redraw of canvas.
		do
			if needs_redraw then
				copy_surface_to_drawing_area
				needs_redraw := False
			end
			internal_drawing_area.redraw
			Result := Current
		end

	invalidate: like Current
			-- Mark canvas as needing redraw.
		do
			needs_redraw := True
			internal_drawing_area.redraw
			Result := Current
		end

feature -- Resize

	resize (a_width, a_height: INTEGER): like Current
			-- Resize canvas.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			if a_width /= canvas_width or a_height /= canvas_height then
				canvas_width := a_width
				canvas_height := a_height
				internal_drawing_area.set_minimum_size (a_width, a_height)
				destroy_surface
				create_surface
				needs_redraw := True
			end
			Result := Current
		end

feature -- Theme

	apply_theme
			-- Apply theme to canvas (typically background).
		do
			internal_drawing_area.set_background_color (tokens.background.to_ev_color)
		end

feature -- Cleanup

	destroy
			-- Release Cairo resources.
		do
			destroy_surface
		end

feature {NONE} -- Implementation

	internal_drawing_area: EV_DRAWING_AREA
			-- Underlying EiffelVision drawing area.

	surface: detachable CAIRO_SURFACE
			-- Cairo image surface for offscreen rendering.

	needs_redraw: BOOLEAN
			-- Does the display need updating?

	create_surface
			-- Create Cairo surface and context.
		local
			l_cairo: SIMPLE_CAIRO
		do
			create l_cairo.make
			surface := l_cairo.create_surface (canvas_width, canvas_height)
			if attached surface as s and then s.is_valid then
				context := l_cairo.create_context (s)
			end
		end

	destroy_surface
			-- Release Cairo surface and context.
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

	copy_surface_to_drawing_area
			-- Copy Cairo surface pixels to EiffelVision drawing area.
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

				-- Copy pixel data directly to drawing area
				create l_managed.share_from_pointer (l_data, canvas_height * l_stride)

				from l_row := 0 until l_row >= canvas_height loop
					from l_col := 0 until l_col >= canvas_width loop
						l_offset := l_row * l_stride + l_col * 4
						-- Cairo ARGB32 format: BGRA on little-endian
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

	on_expose (a_x, a_y, a_width, a_height: INTEGER)
			-- Handle expose event.
		do
			copy_surface_to_drawing_area
		end

	on_resize (a_x, a_y, a_width, a_height: INTEGER)
			-- Handle resize event.
		do
			if a_width > 0 and a_height > 0 then
				if a_width /= canvas_width or a_height /= canvas_height then
					canvas_width := a_width
					canvas_height := a_height
					destroy_surface
					create_surface
					needs_redraw := True
				end
			end
		end

invariant
	drawing_area_attached: internal_drawing_area /= Void

end
