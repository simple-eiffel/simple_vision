note
	description: "Demo: Masked input fields with regex validation and input masking"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_MASKED

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
			l_theme_btn: SV_BUTTON
			l_phone, l_ssn, l_email, l_date_fld: SV_MASKED_FIELD
			l_zip, l_credit, l_ip, l_license: SV_MASKED_FIELD
		do
			Result := window ("Masked Fields Demo - Phase 6.75").size (500, 520)

			-- Fields with TRUE input masking (constrains typing, auto-inserts literals)
			l_phone := phone_field        -- (###) ###-####
			l_ssn := ssn_field            -- ###-##-####
			l_date_fld := date_field      -- ##/##/####
			l_zip := zip_code_field       -- #####
			l_credit := credit_card_field -- #### #### #### ####

			-- Fields with validation only (no input constraint, variable format)
			l_email := email_field
			l_ip := ip_address_field

			-- Custom pattern (validation only, no input mask)
			l_license := masked_field_with ("^[A-Z]{3}-[0-9]{4}$")
			l_license.placeholder ("ABC-1234").set_validation_message ("Enter as ABC-1234").do_nothing

			l_theme_btn := button ("Toggle Dark Mode")
			l_theme_btn.on_click (agent toggle_theme)

			l_main := column.spacing (8).padding (20)
				.add (text ("Masked Input Fields").bold.font_size (16))
				.add (text ("Fields auto-format input; invalid turns red"))
				.add (divider)
				.add (row.spacing (10).add (text ("Phone:").min_width (100)).add (l_phone))
				.add (row.spacing (10).add (text ("SSN:").min_width (100)).add (l_ssn))
				.add (row.spacing (10).add (text ("Email:").min_width (100)).add (l_email))
				.add (row.spacing (10).add (text ("Date (US):").min_width (100)).add (l_date_fld))
				.add (row.spacing (10).add (text ("ZIP Code:").min_width (100)).add (l_zip))
				.add (row.spacing (10).add (text ("Credit Card:").min_width (100)).add (l_credit))
				.add (row.spacing (10).add (text ("IP Address:").min_width (100)).add (l_ip))
				.add (row.spacing (10).add (text ("License Plate:").min_width (100)).add (l_license))
				.add (divider)
				.add (l_theme_btn)

			Result.extend (l_main)
		end

feature {NONE} -- Actions

	toggle_theme
			-- Toggle dark mode.
		do
			theme.toggle_dark_mode
		end

end
