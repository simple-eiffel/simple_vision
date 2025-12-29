note
	description: "Cairo graphics demo for simple_vision Phase 7"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_CAIRO

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Cairo graphics demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor

			-- Create widget references
			create_widgets

			-- Build the UI
			l_win := window ("Cairo Graphics - simple_vision Phase 7")
				.size (500, 500)
				.centered
				.content (
					column
						.spacing (15)
						.padding (20)
						.children (<<
							text ("Cairo Graphics Demo").bold.font_size (18).align_center.id ("label_title"),
							divider,
							create_canvas_section,
							create_waveform_section,
							divider,
							create_button_row
						>>)
				)

			-- Initialize canvas drawing
			draw_demo_shapes

			-- Create application and launch
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature -- Widget References (for testing)

	demo_canvas: SV_CAIRO_CANVAS
			-- Main drawing canvas.

	demo_waveform: SV_WAVEFORM
			-- Audio waveform display.

	status_label: SV_TEXT
			-- Status text label.

feature {NONE} -- Widget Creation

	create_widgets
			-- Create widget references.
		local
			l_samples: ARRAY [INTEGER_16]
		do
			-- Create canvas for shapes and gradients
			demo_canvas := canvas (450, 150).id ("canvas_main")

			-- Create waveform with initial sine wave
			demo_waveform := waveform (450, 80).id ("waveform_audio")
			l_samples := generate_sine_wave (450)
			demo_waveform
				.set_waveform_color_hex (0x3498DB)
				.set_background_color_hex (0x2C3E50)
				.enable_center_line
				.set_samples_i16 (l_samples)

			-- Status label
			status_label := text ("Draw shapes and visualize audio waveforms").id ("label_status")
		end

	create_canvas_section: SV_WIDGET
			-- Create canvas display section.
		do
			Result := card
				.titled ("Cairo Canvas - Shapes & Gradients")
				.content (
					column
						.padding (10)
						.children (<<
							demo_canvas
						>>)
				)
		end

	create_waveform_section: SV_WIDGET
			-- Create waveform display section.
		do
			Result := card
				.titled ("Audio Waveform Display")
				.content (
					column
						.padding (10)
						.spacing (10)
						.children (<<
							demo_waveform,
							row
								.spacing (10)
								.children (<<
									text ("Waveform:"),
									button ("Sine").id ("button_sine").clicked (agent on_sine_wave),
									button ("Square").id ("button_square").clicked (agent on_square_wave),
									button ("Random").id ("button_random").clicked (agent on_random_wave),
									spacer
								>>)
						>>)
				)
		end

	create_button_row: SV_WIDGET
			-- Create bottom button row.
		do
			Result := row
				.spacing (10)
				.children (<<
					status_label,
					spacer,
					button ("Redraw").id ("button_redraw").clicked (agent on_redraw),
					button ("Close").id ("button_close").clicked (agent on_close)
				>>)
		end

feature {NONE} -- Demo Drawing

	draw_demo_shapes
			-- Draw demo shapes on canvas.
		do
			-- Draw gradient background
			demo_canvas.fill_gradient_vertical (0x667eea, 0x764ba2, 0, 0, 450, 150).do_nothing

			-- Draw shapes
			-- Red filled rectangle
			demo_canvas
				.set_color_hex (0xE74C3C)
				.fill_rect (20, 20, 80, 60).do_nothing

			-- Green circle
			demo_canvas
				.set_color_hex (0x27AE60)
				.fill_circle (170, 75, 40).do_nothing

			-- Yellow stroked rectangle
			demo_canvas
				.set_color_hex (0xF1C40F)
				.set_line_width (3.0)
				.stroke_rect (240, 25, 80, 50).do_nothing

			-- Blue circle outline
			demo_canvas
				.set_color_hex (0x3498DB)
				.set_line_width (2.0)
				.stroke_circle (380, 50, 35).do_nothing

			-- Draw line
			demo_canvas
				.set_color_hex (0xFFFFFF)
				.set_line_width (2.0)
				.draw_line (20, 110, 430, 110).do_nothing

			-- Draw text
			demo_canvas
				.set_font ("Arial", 14)
				.set_color_hex (0xFFFFFF)
				.draw_text (120, 135, "Cairo 2D Graphics in simple_vision!").do_nothing

			-- Force display update
			demo_canvas.redraw.do_nothing

			status_label.update_text ("Canvas rendered with Cairo")
		end

feature {NONE} -- Waveform Generation

	generate_sine_wave (a_count: INTEGER): ARRAY [INTEGER_16]
			-- Generate sine wave data.
		local
			l_i: INTEGER
			l_val: REAL_64
			l_pi: REAL_64
		do
			l_pi := 3.14159265358979
			create Result.make_filled (0, 1, a_count)
			from l_i := 1 until l_i > a_count loop
				l_val := (l_i * l_pi * 6 / a_count).sine * 0.7
				l_val := l_val + (l_i * l_pi * 12 / a_count).sine * 0.2
				Result [l_i] := (l_val * 32767).truncated_to_integer.to_integer_16
				l_i := l_i + 1
			end
		ensure
			correct_count: Result.count = a_count
		end

	generate_square_wave (a_count: INTEGER): ARRAY [INTEGER_16]
			-- Generate square wave data.
		local
			l_i: INTEGER
			l_period: INTEGER
			l_val: INTEGER_16
		do
			l_period := a_count // 8
			create Result.make_filled (0, 1, a_count)
			from l_i := 1 until l_i > a_count loop
				if ((l_i - 1) // l_period) \\ 2 = 0 then
					l_val := 20000
				else
					l_val := -20000
				end
				Result [l_i] := l_val
				l_i := l_i + 1
			end
		ensure
			correct_count: Result.count = a_count
		end

	generate_random_wave (a_count: INTEGER): ARRAY [INTEGER_16]
			-- Generate random wave data.
		local
			l_i: INTEGER
			l_val: REAL_64
			l_pi: REAL_64
			l_rand: RANDOM
		do
			l_pi := 3.14159265358979
			create l_rand.make
			l_rand.start
			create Result.make_filled (0, 1, a_count)
			from l_i := 1 until l_i > a_count loop
				l_val := (l_i * l_pi * 4 / a_count).sine * (0.3 + l_rand.double_item * 0.6)
				l_rand.forth
				Result [l_i] := (l_val * 32767).truncated_to_integer.to_integer_16
				l_i := l_i + 1
			end
		ensure
			correct_count: Result.count = a_count
		end

feature {NONE} -- Event Handlers

	on_sine_wave
			-- Display sine wave.
		local
			l_samples: ARRAY [INTEGER_16]
		do
			l_samples := generate_sine_wave (450)
			demo_waveform.set_samples_i16 (l_samples).do_nothing
			status_label.update_text ("Sine wave displayed")
		end

	on_square_wave
			-- Display square wave.
		local
			l_samples: ARRAY [INTEGER_16]
		do
			l_samples := generate_square_wave (450)
			demo_waveform.set_samples_i16 (l_samples).do_nothing
			status_label.update_text ("Square wave displayed")
		end

	on_random_wave
			-- Display random wave.
		local
			l_samples: ARRAY [INTEGER_16]
		do
			l_samples := generate_random_wave (450)
			demo_waveform.set_samples_i16 (l_samples).do_nothing
			status_label.update_text ("Random wave displayed")
		end

	on_redraw
			-- Handle redraw button.
		do
			draw_demo_shapes
		end

	on_close
			-- Handle close button.
		do
			(create {EV_APPLICATION}).destroy
		end

end
