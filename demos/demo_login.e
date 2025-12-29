note
	description: "Login form demo for simple_vision (Phase 2)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_LOGIN

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Login Form demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor

			-- Store references to widgets for event handlers (with IDs for testing)
			username_field := text_field.id ("field_username")
			password_field_widget := password_field.id ("field_password")
			remember_checkbox := checkbox ("Remember me").id ("checkbox_remember")
			status_label := text ("Enter your credentials").id ("label_status")

			-- Build the UI using fluent API
			l_win := window ("Login - simple_vision Demo")
				.size (400, 300)
				.centered
				.content (
					column
						.spacing (15)
						.padding (30)
						.children (<<
							text ("User Login").bold.font_size (18).align_center,
							divider,
							row.spacing (10).children (<<
								text ("Username:").min_width (80),
								username_field.placeholder ("Enter username")
							>>),
							row.spacing (10).children (<<
								text ("Password:").min_width (80),
								password_field_widget.placeholder ("Enter password")
							>>),
							remember_checkbox.unchecked,
							spacer,
							status_label.align_center,
							row.spacing (10).children (<<
								spacer,
								button ("Cancel").id ("button_cancel").clicked (agent on_cancel),
								button ("Login").id ("button_login").clicked (agent on_login),
								spacer
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

	username_field: SV_TEXT_FIELD
	password_field_widget: SV_PASSWORD_FIELD
	remember_checkbox: SV_CHECKBOX
	status_label: SV_TEXT

feature {NONE} -- Event Handlers

	on_login
			-- Handle login button click.
		do
			if username_field.text.is_empty then
				status_label.update_text ("Please enter username")
			elseif password_field_widget.text.is_empty then
				status_label.update_text ("Please enter password")
			else
				status_label.update_text ("Logging in as " + username_field.text.to_string_8 + "...")
			end
		end

	on_cancel
			-- Handle cancel button.
		do
			username_field.clear
			password_field_widget.clear
			remember_checkbox.uncheck_now
			status_label.update_text ("Enter your credentials")
		end

end
