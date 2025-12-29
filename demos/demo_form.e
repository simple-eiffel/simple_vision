note
	description: "Demo: Form validation system with SV_FORM and SV_FIELD"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_FORM

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create demo application.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor
			create l_app.make
			l_win := build_ui
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature {NONE} -- UI Building

	build_ui: SV_WINDOW
			-- Build the main UI.
		local
			l_main: SV_COLUMN
			l_form_widget: SV_WIDGET
			l_submit_btn, l_reset_btn, l_theme_btn: SV_BUTTON
			l_button_row: SV_ROW
			l_status: SV_TEXT
		do
			Result := window ("Form Validation Demo - Phase 6.75").size (500, 450)

			-- Create form with fields
			create registration_form.make

			-- Username field
			registration_form.add_field (
				field ("username")
					.set_label ("Username")
					.required
					.min_length (3)
					.max_length (20)
					.pattern_with_message ("^[a-zA-Z0-9_]+$", "Only letters, numbers, and underscores")
					.set_placeholder ("Enter username")
					.set_help_text ("3-20 characters, letters/numbers/underscores only")
			)

			-- Email field
			registration_form.add_field (
				field ("email")
					.set_label ("Email")
					.required
					.email
					.set_placeholder ("user@example.com")
			)

			-- Password field
			registration_form.add_field (
				field ("password")
					.set_label ("Password")
					.required
					.min_length (8)
					.as_password
					.set_placeholder ("Enter password")
					.set_help_text ("Minimum 8 characters")
			)

			-- Phone field (masked)
			registration_form.add_field (
				field ("phone")
					.set_label ("Phone")
					.set_placeholder ("(123) 456-7890")
					.as_masked ("^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$")
			)

			-- Build the form UI
			l_form_widget := registration_form.build

			-- Status label for showing results
			status_label := text ("Fill out the form and click Submit")

			-- Buttons
			l_submit_btn := button ("Submit")
			l_submit_btn.on_click (agent on_submit)

			l_reset_btn := button ("Reset")
			l_reset_btn.on_click (agent on_reset)

			l_theme_btn := button ("Toggle Dark Mode")
			l_theme_btn.on_click (agent toggle_theme)

			l_button_row := row.spacing (10)
				.add (l_submit_btn)
				.add (l_reset_btn)
				.add (l_theme_btn)

			-- Main layout
			l_main := column.spacing (12).padding (20)
				.add (text ("User Registration Form").bold.font_size (16))
				.add (text ("Demonstrates SV_FORM validation system"))
				.add (divider)
				.add (l_form_widget)
				.add (divider)
				.add (l_button_row)
				.add (status_label)

			Result.extend (l_main)

			-- Wire up form events
			registration_form.on_submit (agent on_form_submit)
			registration_form.on_error (agent on_form_error)
		end

feature {NONE} -- Form

	registration_form: SV_FORM
			-- The registration form.

	status_label: SV_TEXT
			-- Status display.

feature {NONE} -- Actions

	on_submit
			-- Handle submit button click.
		do
			registration_form.mark_all_touched
			registration_form.submit
		end

	on_reset
			-- Handle reset button click.
		do
			registration_form.reset
			status_label.update_text ("Form reset")
		end

	on_form_submit (a_values: HASH_TABLE [STRING_32, STRING])
			-- Handle successful form submission.
		local
			l_msg: STRING
		do
			create l_msg.make (200)
			l_msg.append ("SUCCESS! Values:%N")
			from a_values.start until a_values.after loop
				l_msg.append ("  " + a_values.key_for_iteration + ": " + a_values.item_for_iteration.to_string_8 + "%N")
				a_values.forth
			end
			status_label.update_text (l_msg)
		end

	on_form_error (a_errors: HASH_TABLE [STRING, STRING])
			-- Handle form validation errors.
		local
			l_msg: STRING
		do
			create l_msg.make (200)
			l_msg.append ("ERRORS:%N")
			from a_errors.start until a_errors.after loop
				l_msg.append ("  " + a_errors.key_for_iteration + ": " + a_errors.item_for_iteration + "%N")
				a_errors.forth
			end
			status_label.update_text (l_msg)
		end

	toggle_theme
			-- Toggle dark mode.
		do
			theme.toggle_dark_mode
		end

end
