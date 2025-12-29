note
	description: "Hello World demo for simple_vision"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_HELLO

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Hello World demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
			l_label: SV_TEXT
		do
			Precursor

			-- Create the label (we need a reference to update it)
			l_label := text ("Click the button!")

			-- Build the UI using fluent API
			l_win := window ("simple_vision Demo")
				.size (400, 200)
				.centered
				.content (
					column
						.spacing (10)
						.padding (20)
						.children (<<
							text ("Hello, simple_vision!").bold.font_size (16).align_center,
							l_label.align_center,
							row
								.spacing (10)
								.children (<<
									button ("Click Me!").clicked (agent on_button_click (l_label)),
									button ("Quit").clicked (agent on_quit)
								>>)
						>>)
				)

			-- Create application and launch
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature {NONE} -- Event Handlers

	click_count: INTEGER
			-- Number of times the button was clicked.

	on_button_click (a_label: SV_TEXT)
			-- Handle button click.
		do
			click_count := click_count + 1
			a_label.update_text ("Clicked " + click_count.out + " time" +
				(if click_count = 1 then "" else "s" end) + "!")
		end

	on_quit
			-- Handle quit button.
		do
			(create {EV_APPLICATION}).destroy
		end

end
