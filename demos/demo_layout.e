note
	description: "Complex layout demo for simple_vision (Phase 3)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_LAYOUT

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Complex Layout demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor

			-- Create widgets with IDs for testing
			status_text := text ("Ready").id ("label_status")
			notifications_checkbox := checkbox ("Enable notifications").id ("checkbox_notifications")
			autosave_checkbox := checkbox ("Auto-save").id ("checkbox_autosave")
			darkmode_checkbox := checkbox ("Dark mode").id ("checkbox_darkmode")
			refresh_button := button ("Refresh").id ("button_refresh")
			clear_button := button ("Clear").id ("button_clear")

			-- Build the UI using fluent API
			l_win := window ("Complex Layout - simple_vision Demo")
				.size (800, 600)
				.centered
				.content (
					column.children (<<
						-- Top section with cards
						row.spacing (10).padding (10).children (<<
							card_titled ("Settings")
								.content (
									column.spacing (5).padding (10).children (<<
										notifications_checkbox.checked,
										autosave_checkbox.checked,
										darkmode_checkbox.unchecked,
										separator_horizontal
									>>)
								).raised,
							card_titled ("Statistics")
								.content (
									grid_sized (2, 3).gap (5).border (5)
										.put (text ("Users:"), 1, 1)
										.put (text ("1,234"), 2, 1)
										.put (text ("Sessions:"), 1, 2)
										.put (text ("567"), 2, 2)
										.put (text ("Uptime:"), 1, 3)
										.put (text ("99.9%%"), 2, 3)
								).etched
						>>),
						-- Middle section with tabs and splitter
						horizontal_splitter
							.left (
								tabs
									.tab ("Overview", text ("Overview content goes here"))
									.tab ("Details", column.children (<<
										text ("Item 1"),
										text ("Item 2"),
										text ("Item 3")
									>>))
									.tab ("Settings", text ("Settings panel"))
							)
							.right (
								card_titled ("Preview")
									.content (
										column.spacing (10).padding (10).children (<<
											text ("Preview Area").bold,
											spacer,
											row.children (<<
												refresh_button.clicked (agent on_refresh),
												spacer,
												clear_button.clicked (agent on_clear)
											>>)
										>>)
									)
							)
							.at_proportion (0.6),
						-- Bottom status
						row.spacing (5).padding (5).children (<<
							status_text,
							spacer,
							text ("Layout Demo v1.0")
						>>)
					>>)
				)

			-- Create application and launch
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature -- Widget References (for testing)

	status_text: SV_TEXT
	notifications_checkbox: SV_CHECKBOX
	autosave_checkbox: SV_CHECKBOX
	darkmode_checkbox: SV_CHECKBOX
	refresh_button: SV_BUTTON
	clear_button: SV_BUTTON

feature {NONE} -- Event Handlers

	on_refresh
			-- Handle refresh button.
		do
			status_text.update_text ("Refreshed at " + (create {TIME}.make_now).out)
		end

	on_clear
			-- Handle clear button.
		do
			status_text.update_text ("Cleared")
		end

end
