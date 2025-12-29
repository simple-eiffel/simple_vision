note
	description: "Theme settings demo for simple_vision (Phase 6)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_THEME

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Theme Settings demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor

			-- Store references to widgets for event handlers
			create_widgets

			-- Build the UI
			l_win := window ("Theme Settings - simple_vision Demo")
				.size (600, 500)
				.centered
				.content (
					column
						.spacing (15)
						.padding (20)
						.children (<<
							text ("Theme Settings").bold.font_size (20).align_center.id ("label_title"),
							divider,
							create_theme_mode_section,
							create_color_scheme_section,
							create_scale_section,
							spacer,
							create_preview_section,
							divider,
							create_button_row
						>>)
				)

			-- Initialize display
			update_scale_display
			update_preview

			-- Create application and launch
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature -- Widget References (for testing)

	theme_mode_group: SV_RADIO_GROUP
	color_scheme_dropdown: SV_DROPDOWN
	ui_scale_label: SV_TEXT
	font_scale_label: SV_TEXT
	preview_primary: SV_TEXT
	preview_secondary: SV_TEXT
	preview_background: SV_TEXT
	preview_surface: SV_TEXT

feature {NONE} -- Widget Creation

	create_widgets
			-- Create widget references.
		do
			-- Radio group for theme mode
			theme_mode_group := radio_group.options (<<"Light", "Dark", "System">>)
				.horizontal.id ("radio_theme_mode")

			-- Color scheme dropdown
			color_scheme_dropdown := dropdown_with (<<"Material (Purple)", "Blue", "Green", "Orange", "Red", "Teal">>).id ("dropdown_scheme")

			-- Scale labels
			ui_scale_label := text ("100%%").id ("label_ui_scale").min_width (50)
			font_scale_label := text ("100%%").id ("label_font_scale").min_width (50)

			-- Preview labels
			preview_primary := text ("Primary").id ("label_preview_primary").min_width (100)
			preview_secondary := text ("Secondary").id ("label_preview_secondary").min_width (100)
			preview_background := text ("Background").id ("label_preview_background").min_width (100)
			preview_surface := text ("Surface").id ("label_preview_surface").min_width (100)
		end

	create_theme_mode_section: SV_WIDGET
			-- Create theme mode radio button section.
		do
			-- Select current mode
			inspect theme.theme_mode
			when {SV_THEME}.Mode_light then
				theme_mode_group.select_index (1)
			when {SV_THEME}.Mode_dark then
				theme_mode_group.select_index (2)
			when {SV_THEME}.Mode_system then
				theme_mode_group.select_index (3)
			end

			-- Attach handler
			theme_mode_group.on_change (agent on_theme_mode_change)

			Result := card
				.titled ("Theme Mode")
				.content (
					row
						.padding (10)
						.children (<<
							theme_mode_group
						>>)
				)
		end

	create_color_scheme_section: SV_WIDGET
			-- Create color scheme dropdown section.
		local
			l_index: INTEGER
		do
			-- Set current scheme
			l_index := scheme_to_index (theme.color_scheme)
			if l_index > 0 then
				color_scheme_dropdown.select_index (l_index)
			end

			color_scheme_dropdown.on_select (agent on_scheme_change)

			Result := card
				.titled ("Color Scheme")
				.content (
					row
						.padding (10)
						.children (<<
							color_scheme_dropdown.min_width (200),
							spacer
						>>)
				)
		end

	create_scale_section: SV_WIDGET
			-- Create UI and font scale controls.
		do
			Result := card
				.titled ("Accessibility")
				.content (
					column
						.spacing (15)
						.padding (10)
						.children (<<
							row.spacing (10).children (<<
								text ("UI Scale:").min_width (100),
								button ("-").id ("button_ui_decrease").clicked (agent on_ui_scale_decrease).min_width (40),
								ui_scale_label.align_center,
								button ("+").id ("button_ui_increase").clicked (agent on_ui_scale_increase).min_width (40),
								spacer,
								button ("Reset").id ("button_ui_reset").clicked (agent on_ui_scale_reset)
							>>),
							row.spacing (10).children (<<
								text ("Font Scale:").min_width (100),
								button ("-").id ("button_font_decrease").clicked (agent on_font_scale_decrease).min_width (40),
								font_scale_label.align_center,
								button ("+").id ("button_font_increase").clicked (agent on_font_scale_increase).min_width (40),
								spacer,
								button ("Reset").id ("button_font_reset").clicked (agent on_font_scale_reset)
							>>)
						>>)
				)
		end

	create_preview_section: SV_WIDGET
			-- Create color preview section.
		do
			Result := card
				.titled ("Color Preview")
				.content (
					row
						.spacing (10)
						.padding (10)
						.children (<<
							preview_primary,
							preview_secondary,
							preview_background,
							preview_surface
						>>)
				)
		end

	create_button_row: SV_WIDGET
			-- Create bottom button row.
		do
			Result := row
				.spacing (10)
				.children (<<
					spacer,
					button ("Reset All").id ("button_reset_all").clicked (agent on_reset_all),
					button ("Close").id ("button_close").clicked (agent on_close)
				>>)
		end

feature {NONE} -- Event Handlers: Theme Mode

	on_theme_mode_change (a_value: STRING)
			-- Handle theme mode radio selection.
		do
			if a_value.same_string ("Light") then
				theme.set_theme_mode ({SV_THEME}.Mode_light)
			elseif a_value.same_string ("Dark") then
				theme.set_theme_mode ({SV_THEME}.Mode_dark)
			elseif a_value.same_string ("System") then
				theme.set_theme_mode ({SV_THEME}.Mode_system)
			end
			update_preview
		end

feature {NONE} -- Event Handlers: Color Scheme

	on_scheme_change
			-- Handle color scheme dropdown change.
		local
			l_scheme: STRING
		do
			inspect color_scheme_dropdown.selected_index
			when 1 then l_scheme := "material"
			when 2 then l_scheme := "blue"
			when 3 then l_scheme := "green"
			when 4 then l_scheme := "orange"
			when 5 then l_scheme := "red"
			when 6 then l_scheme := "teal"
			else l_scheme := "material"
			end
			theme.set_color_scheme (l_scheme)
			update_preview
		end

feature {NONE} -- Event Handlers: Scaling

	on_ui_scale_increase
			-- Increase UI scale.
		do
			theme.increase_scale
			update_scale_display
		end

	on_ui_scale_decrease
			-- Decrease UI scale.
		do
			theme.decrease_scale
			update_scale_display
		end

	on_ui_scale_reset
			-- Reset UI scale to 100%.
		do
			theme.reset_scale
			update_scale_display
		end

	on_font_scale_increase
			-- Increase font scale.
		do
			theme.set_font_scale ((theme.font_scale + 0.1).min (3.0))
			update_scale_display
		end

	on_font_scale_decrease
			-- Decrease font scale.
		do
			theme.set_font_scale ((theme.font_scale - 0.1).max (0.5))
			update_scale_display
		end

	on_font_scale_reset
			-- Reset font scale to 100%.
		do
			theme.set_font_scale (1.0)
			update_scale_display
		end

feature {NONE} -- Event Handlers: Buttons

	on_reset_all
			-- Reset all settings to defaults.
		do
			theme.set_theme_mode ({SV_THEME}.Mode_light)
			theme.set_color_scheme ("material")
			theme.reset_scale
			theme.set_font_scale (1.0)

			-- Update UI to reflect reset
			theme_mode_group.select_index (1)
			color_scheme_dropdown.select_index (1)
			update_scale_display
			update_preview
		end

	on_close
			-- Handle close button.
		do
			-- Window close is handled by the window's close action
		end

feature {NONE} -- UI Update

	update_scale_display
			-- Update scale percentage labels.
		do
			ui_scale_label.update_text ((theme.ui_scale * 100).rounded.out + "%%")
			font_scale_label.update_text ((theme.font_scale * 100).rounded.out + "%%")
		end

	update_preview
			-- Update color preview labels.
		do
			-- Update text and background colors would require widget styling
			-- For now, just show the hex values
			preview_primary.update_text ("Primary: " + tokens.primary.to_hex)
			preview_secondary.update_text ("Secondary: " + tokens.secondary.to_hex)
			preview_background.update_text ("BG: " + tokens.background.to_hex)
			preview_surface.update_text ("Surface: " + tokens.surface.to_hex)
		end

feature {NONE} -- Helpers

	scheme_to_index (a_scheme: STRING): INTEGER
			-- Convert scheme name to dropdown index.
		do
			if a_scheme.same_string ("material") then
				Result := 1
			elseif a_scheme.same_string ("blue") then
				Result := 2
			elseif a_scheme.same_string ("green") then
				Result := 3
			elseif a_scheme.same_string ("orange") then
				Result := 4
			elseif a_scheme.same_string ("red") then
				Result := 5
			elseif a_scheme.same_string ("teal") then
				Result := 6
			else
				Result := 1
			end
		end

end
