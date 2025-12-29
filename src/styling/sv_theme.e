note
	description: "Theme manager for simple_vision - singleton pattern with light/dark modes and font scaling"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_THEME

create {SV_THEME, SV_QUICK, SV_ANY}
	make_internal

feature {NONE} -- Initialization

	make_internal
			-- Create theme manager with light theme.
		do
			create tokens.make
			create on_theme_change
			create on_font_scale_change
			is_dark_mode := False
			theme_mode := Mode_light
			font_scale := 1.0
			load_material_light
			load_user_preferences
		end

feature -- Access

	tokens: SV_TOKENS
			-- Current design tokens.

	is_dark_mode: BOOLEAN
			-- Is dark mode currently active?

	theme_mode: INTEGER
			-- Current theme mode.
			-- See mode constants below.
		attribute
			Result := Mode_light
		end

	color_scheme: STRING
			-- Current color scheme name.
		attribute
			Result := "material"
		end

	font_scale: REAL
			-- Font size scale factor (1.0 = 100%, 1.5 = 150%, etc.).
			-- Affects all font sizes.

	ui_scale: REAL
			-- Overall UI scale factor (like browser zoom).
			-- Affects fonts, spacing, borders - everything proportionally.
		attribute
			Result := 1.0
		end

feature -- Theme Mode Constants

	Mode_light: INTEGER = 1
			-- Light mode.

	Mode_dark: INTEGER = 2
			-- Dark mode.

	Mode_system: INTEGER = 3
			-- Follow system/OS preference.

feature -- Theme Switching

	set_theme_mode (a_mode: INTEGER)
			-- Set theme mode (light, dark, or system).
		require
			valid_mode: a_mode >= Mode_light and a_mode <= Mode_system
		local
			l_old_tokens: SV_TOKENS
		do
			theme_mode := a_mode
			l_old_tokens := tokens.twin
			inspect a_mode
			when Mode_light then
				is_dark_mode := False
				apply_color_scheme (color_scheme, False)
			when Mode_dark then
				is_dark_mode := True
				apply_color_scheme (color_scheme, True)
			when Mode_system then
				is_dark_mode := detect_system_dark_mode
				apply_color_scheme (color_scheme, is_dark_mode)
			end
			on_theme_change.call ([l_old_tokens, tokens])
			save_user_preferences
		ensure
			mode_set: theme_mode = a_mode
		end

	is_system_mode: BOOLEAN
			-- Is theme following system preference?
		do
			Result := theme_mode = Mode_system
		end

	detect_system_dark_mode: BOOLEAN
			-- Detect if OS is in dark mode.
			-- Windows: Check registry for AppsUseLightTheme
		local
			l_env: EXECUTION_ENVIRONMENT
		do
			-- On Windows, dark mode is indicated by registry key
			-- HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme = 0
			-- For now, default to light mode; can enhance with actual registry read later
			create l_env
			if attached l_env.item ("SIMPLE_VISION_DARK_MODE") as l_val then
				Result := l_val.same_string ("1") or l_val.same_string ("true")
			else
				-- Default to light mode
				Result := False
			end
		end

	toggle_dark_mode
			-- Toggle between light and dark mode.
		do
			set_dark_mode (not is_dark_mode)
		ensure
			toggled: is_dark_mode = not old is_dark_mode
		end

	set_dark_mode (a_dark: BOOLEAN)
			-- Set dark mode on or off.
		local
			l_old_tokens: SV_TOKENS
		do
			if a_dark /= is_dark_mode then
				l_old_tokens := tokens.twin
				is_dark_mode := a_dark
				if is_dark_mode then
					load_material_dark
				else
					load_material_light
				end
				on_theme_change.call ([l_old_tokens, tokens])
			end
		ensure
			mode_set: is_dark_mode = a_dark
		end

feature -- Theme Loading

	load_material_light
			-- Load Material Design 3 light theme.
		do
			-- Primary colors
			tokens.set_primary (create {SV_COLOR}.make_from_hex ("#6750A4"))
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#625B71"))
			tokens.set_background (create {SV_COLOR}.make_from_hex ("#FFFBFE"))
			tokens.set_surface (create {SV_COLOR}.make_from_hex ("#FFFBFE"))
			tokens.set_error (create {SV_COLOR}.make_from_hex ("#B3261E"))

			-- On-colors (text on backgrounds)
			tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
			tokens.set_on_secondary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
			tokens.set_on_background (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_on_surface (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_on_error (create {SV_COLOR}.make_from_hex ("#FFFFFF"))

			-- Text colors
			tokens.set_text_primary (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_text_secondary (create {SV_COLOR}.make_from_hex ("#49454F"))
			tokens.set_text_hint (create {SV_COLOR}.make_from_hex ("#79747E"))

			-- Utility colors
			tokens.set_border (create {SV_COLOR}.make_from_hex ("#79747E"))
			tokens.set_divider (create {SV_COLOR}.make_from_hex ("#CAC4D0"))
			tokens.set_surface_variant (create {SV_COLOR}.make_from_hex ("#E7E0EC"))

			-- Status colors
			tokens.set_success (create {SV_COLOR}.make_from_hex ("#2E7D32"))
			tokens.set_warning (create {SV_COLOR}.make_from_hex ("#F9A825"))
			tokens.set_info (create {SV_COLOR}.make_from_hex ("#0288D1"))
		end

	load_material_dark
			-- Load Material Design 3 dark theme.
		do
			-- Primary colors (lighter for dark backgrounds)
			tokens.set_primary (create {SV_COLOR}.make_from_hex ("#D0BCFF"))
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#CCC2DC"))
			tokens.set_background (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_surface (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_error (create {SV_COLOR}.make_from_hex ("#F2B8B5"))

			-- On-colors (text on backgrounds - darker for light text)
			tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#381E72"))
			tokens.set_on_secondary (create {SV_COLOR}.make_from_hex ("#332D41"))
			tokens.set_on_background (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_on_surface (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_on_error (create {SV_COLOR}.make_from_hex ("#601410"))

			-- Text colors
			tokens.set_text_primary (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_text_secondary (create {SV_COLOR}.make_from_hex ("#CAC4D0"))
			tokens.set_text_hint (create {SV_COLOR}.make_from_hex ("#938F99"))

			-- Utility colors
			tokens.set_border (create {SV_COLOR}.make_from_hex ("#938F99"))
			tokens.set_divider (create {SV_COLOR}.make_from_hex ("#49454F"))
			tokens.set_surface_variant (create {SV_COLOR}.make_from_hex ("#49454F"))

			-- Status colors (adjusted for dark mode)
			tokens.set_success (create {SV_COLOR}.make_from_hex ("#81C784"))
			tokens.set_warning (create {SV_COLOR}.make_from_hex ("#FFD54F"))
			tokens.set_info (create {SV_COLOR}.make_from_hex ("#4FC3F7"))
		end

	load_custom (a_tokens: SV_TOKENS)
			-- Load custom tokens.
		require
			tokens_valid: a_tokens /= Void
		local
			l_old_tokens: SV_TOKENS
		do
			l_old_tokens := tokens.twin
			tokens := a_tokens
			on_theme_change.call ([l_old_tokens, tokens])
		ensure
			tokens_set: tokens = a_tokens
		end

feature -- Color Schemes

	available_color_schemes: ARRAY [STRING]
			-- List of available color scheme names.
		once
			Result := <<"material", "blue", "green", "orange", "red", "teal">>
		end

	set_color_scheme (a_scheme: STRING)
			-- Set color scheme by name.
		require
			valid_scheme: a_scheme /= Void and then not a_scheme.is_empty
		do
			color_scheme := a_scheme.as_lower
			apply_color_scheme (color_scheme, is_dark_mode)
			save_user_preferences
		ensure
			scheme_set: color_scheme.same_string (a_scheme.as_lower)
		end

	apply_color_scheme (a_scheme: STRING; a_dark: BOOLEAN)
			-- Apply a color scheme in light or dark mode.
		do
			if a_scheme.same_string ("blue") then
				apply_blue_scheme (a_dark)
			elseif a_scheme.same_string ("green") then
				apply_green_scheme (a_dark)
			elseif a_scheme.same_string ("orange") then
				apply_orange_scheme (a_dark)
			elseif a_scheme.same_string ("red") then
				apply_red_scheme (a_dark)
			elseif a_scheme.same_string ("teal") then
				apply_teal_scheme (a_dark)
			else
				-- Default: Material purple
				if a_dark then
					load_material_dark
				else
					load_material_light
				end
			end
		end

	apply_blue_scheme (a_dark: BOOLEAN)
			-- Apply blue color scheme.
		do
			if a_dark then
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#90CAF9"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#0D47A1"))
				load_dark_base_colors
			else
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#1976D2"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
				load_light_base_colors
			end
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#42A5F5"))
		end

	apply_green_scheme (a_dark: BOOLEAN)
			-- Apply green color scheme.
		do
			if a_dark then
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#A5D6A7"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#1B5E20"))
				load_dark_base_colors
			else
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#388E3C"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
				load_light_base_colors
			end
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#66BB6A"))
		end

	apply_orange_scheme (a_dark: BOOLEAN)
			-- Apply orange color scheme.
		do
			if a_dark then
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#FFCC80"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#E65100"))
				load_dark_base_colors
			else
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#F57C00"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
				load_light_base_colors
			end
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#FFA726"))
		end

	apply_red_scheme (a_dark: BOOLEAN)
			-- Apply red color scheme.
		do
			if a_dark then
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#EF9A9A"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#B71C1C"))
				load_dark_base_colors
			else
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#D32F2F"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
				load_light_base_colors
			end
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#EF5350"))
		end

	apply_teal_scheme (a_dark: BOOLEAN)
			-- Apply teal color scheme.
		do
			if a_dark then
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#80CBC4"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#004D40"))
				load_dark_base_colors
			else
				tokens.set_primary (create {SV_COLOR}.make_from_hex ("#00796B"))
				tokens.set_on_primary (create {SV_COLOR}.make_from_hex ("#FFFFFF"))
				load_light_base_colors
			end
			tokens.set_secondary (create {SV_COLOR}.make_from_hex ("#26A69A"))
		end

feature {NONE} -- Base Color Helpers

	load_light_base_colors
			-- Load light mode base colors (background, surface, text).
		do
			tokens.set_background (create {SV_COLOR}.make_from_hex ("#FFFBFE"))
			tokens.set_surface (create {SV_COLOR}.make_from_hex ("#FFFBFE"))
			tokens.set_on_background (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_on_surface (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_text_primary (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_text_secondary (create {SV_COLOR}.make_from_hex ("#49454F"))
			tokens.set_text_hint (create {SV_COLOR}.make_from_hex ("#79747E"))
			tokens.set_border (create {SV_COLOR}.make_from_hex ("#79747E"))
			tokens.set_divider (create {SV_COLOR}.make_from_hex ("#CAC4D0"))
			tokens.set_surface_variant (create {SV_COLOR}.make_from_hex ("#E7E0EC"))
		end

	load_dark_base_colors
			-- Load dark mode base colors (background, surface, text).
		do
			tokens.set_background (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_surface (create {SV_COLOR}.make_from_hex ("#1C1B1F"))
			tokens.set_on_background (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_on_surface (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_text_primary (create {SV_COLOR}.make_from_hex ("#E6E1E5"))
			tokens.set_text_secondary (create {SV_COLOR}.make_from_hex ("#CAC4D0"))
			tokens.set_text_hint (create {SV_COLOR}.make_from_hex ("#938F99"))
			tokens.set_border (create {SV_COLOR}.make_from_hex ("#938F99"))
			tokens.set_divider (create {SV_COLOR}.make_from_hex ("#49454F"))
			tokens.set_surface_variant (create {SV_COLOR}.make_from_hex ("#49454F"))
		end

feature -- UI Scaling (Accessibility)

	set_ui_scale (a_scale: REAL)
			-- Set overall UI scale (like browser zoom).
			-- 1.0 = 100%, 1.25 = 125%, 1.5 = 150%, 2.0 = 200%
		require
			valid_scale: a_scale >= 0.5 and a_scale <= 3.0
		local
			l_old_scale: REAL
		do
			l_old_scale := ui_scale
			ui_scale := a_scale
			on_font_scale_change.call ([l_old_scale, a_scale])
			save_user_preferences
		ensure
			scale_set: ui_scale = a_scale
		end

	increase_scale
			-- Increase UI scale by one step (like Ctrl++).
		do
			if ui_scale < 3.0 then
				set_ui_scale ((ui_scale + 0.1).min (3.0))
			end
		end

	decrease_scale
			-- Decrease UI scale by one step (like Ctrl+-).
		do
			if ui_scale > 0.5 then
				set_ui_scale ((ui_scale - 0.1).max (0.5))
			end
		end

	reset_scale
			-- Reset UI scale to 100%.
		do
			set_ui_scale (1.0)
		ensure
			reset: ui_scale = 1.0
		end

	set_font_scale (a_scale: REAL)
			-- Set font-only scale (separate from UI scale).
		require
			valid_scale: a_scale >= 0.5 and a_scale <= 3.0
		local
			l_old_scale: REAL
		do
			l_old_scale := font_scale
			font_scale := a_scale
			on_font_scale_change.call ([l_old_scale, a_scale])
			save_user_preferences
		ensure
			scale_set: font_scale = a_scale
		end

feature -- Scaled Values (Apply scaling to base values)

	scaled_font_size (a_base_size: INTEGER): INTEGER
			-- Apply both font_scale and ui_scale to base font size.
		do
			Result := (a_base_size.to_real * font_scale * ui_scale).rounded
		ensure
			positive: Result > 0
		end

	scaled_size (a_base_size: INTEGER): INTEGER
			-- Apply ui_scale to any size value (spacing, borders, etc.).
		do
			Result := (a_base_size.to_real * ui_scale).rounded.max (1)
		ensure
			positive: Result >= 1
		end

	font_size_xs: INTEGER do Result := scaled_font_size (tokens.font_size_xs) end
	font_size_sm: INTEGER do Result := scaled_font_size (tokens.font_size_sm) end
	font_size_md: INTEGER do Result := scaled_font_size (tokens.font_size_md) end
	font_size_lg: INTEGER do Result := scaled_font_size (tokens.font_size_lg) end
	font_size_xl: INTEGER do Result := scaled_font_size (tokens.font_size_xl) end

	space_xs: INTEGER do Result := scaled_size (tokens.space_xs) end
	space_sm: INTEGER do Result := scaled_size (tokens.space_sm) end
	space_md: INTEGER do Result := scaled_size (tokens.space_md) end
	space_lg: INTEGER do Result := scaled_size (tokens.space_lg) end
	space_xl: INTEGER do Result := scaled_size (tokens.space_xl) end

	scaled_font: EV_FONT
			-- Create a font with scaled medium size.
		do
			create Result.make_with_values ({EV_FONT_CONSTANTS}.family_sans, {EV_FONT_CONSTANTS}.weight_regular, {EV_FONT_CONSTANTS}.shape_regular, font_size_md)
		end

	scaled_font_with_size (a_base_size: INTEGER): EV_FONT
			-- Create a font with specified base size, scaled.
		do
			create Result.make_with_values ({EV_FONT_CONSTANTS}.family_sans, {EV_FONT_CONSTANTS}.weight_regular, {EV_FONT_CONSTANTS}.shape_regular, scaled_font_size (a_base_size))
		end

	scaled_font_bold: EV_FONT
			-- Create a bold font with scaled medium size.
		do
			create Result.make_with_values ({EV_FONT_CONSTANTS}.family_sans, {EV_FONT_CONSTANTS}.weight_bold, {EV_FONT_CONSTANTS}.shape_regular, font_size_md)
		end

feature -- Preference Persistence

	preferences_file_path: STRING
			-- Path to user preferences file.
		local
			l_env: EXECUTION_ENVIRONMENT
		once
			create l_env
			if attached l_env.home_directory_path as l_home then
				Result := l_home.name.to_string_8 + "/.simple_vision_prefs.json"
			else
				Result := ".simple_vision_prefs.json"
			end
		end

	save_user_preferences
			-- Save user preferences to file.
		local
			l_file: PLAIN_TEXT_FILE
			l_json: STRING
		do
			l_json := "{%N"
			l_json.append ("  %"ui_scale%": " + ui_scale.out + ",%N")
			l_json.append ("  %"font_scale%": " + font_scale.out + ",%N")
			l_json.append ("  %"dark_mode%": " + is_dark_mode.out.as_lower + "%N")
			l_json.append ("}%N")

			create l_file.make_open_write (preferences_file_path)
			l_file.put_string (l_json)
			l_file.close
		rescue
			-- Ignore file write errors (permissions, etc.)
		end

	load_user_preferences
			-- Load user preferences from file if exists.
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
			l_scale_str: STRING
			l_dark_str: STRING
		do
			create l_file.make_with_name (preferences_file_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				l_file.close

				-- Simple JSON parsing (avoid dependency on simple_json for now)
				if l_content.has_substring ("ui_scale") then
					l_scale_str := extract_json_number (l_content, "ui_scale")
					if l_scale_str /= Void and then l_scale_str.is_real then
						ui_scale := l_scale_str.to_real.max (0.5).min (3.0)
					end
				end
				if l_content.has_substring ("font_scale") then
					l_scale_str := extract_json_number (l_content, "font_scale")
					if l_scale_str /= Void and then l_scale_str.is_real then
						font_scale := l_scale_str.to_real.max (0.5).min (3.0)
					end
				end
				if l_content.has_substring ("dark_mode") then
					l_dark_str := extract_json_boolean (l_content, "dark_mode")
					if l_dark_str /= Void then
						if l_dark_str.same_string ("true") then
							is_dark_mode := True
							theme_mode := Mode_dark
							load_material_dark
						end
					end
				end
			end
		rescue
			-- Ignore file read errors
		end

feature {NONE} -- JSON Helpers

	extract_json_number (a_json, a_key: STRING): detachable STRING
			-- Extract number value for key from JSON string.
		local
			l_key_pos, l_colon_pos, l_end_pos: INTEGER
		do
			l_key_pos := a_json.substring_index ("%"" + a_key + "%"", 1)
			if l_key_pos > 0 then
				l_colon_pos := a_json.index_of (':', l_key_pos)
				if l_colon_pos > 0 then
					l_end_pos := a_json.index_of (',', l_colon_pos)
					if l_end_pos = 0 then
						l_end_pos := a_json.index_of ('}', l_colon_pos)
					end
					if l_end_pos > l_colon_pos then
						Result := a_json.substring (l_colon_pos + 1, l_end_pos - 1)
						Result.left_adjust
						Result.right_adjust
					end
				end
			end
		end

	extract_json_boolean (a_json, a_key: STRING): detachable STRING
			-- Extract boolean value for key from JSON string.
		do
			Result := extract_json_number (a_json, a_key)
			if Result /= Void then
				Result.to_lower
			end
		end

feature -- Events

	on_theme_change: ACTION_SEQUENCE [TUPLE [old_tokens: SV_TOKENS; new_tokens: SV_TOKENS]]
			-- Called when theme changes.

	on_font_scale_change: ACTION_SEQUENCE [TUPLE [old_scale: REAL; new_scale: REAL]]
			-- Called when UI/font scale changes.

feature -- Singleton

	shared: SV_THEME
			-- Global theme instance (singleton).
		once
			create Result.make_internal
		end

feature -- Convenience Queries (delegate to tokens)

	primary: SV_COLOR
			-- Primary color from current tokens.
		do
			Result := tokens.primary
		end

	secondary: SV_COLOR
			-- Secondary color from current tokens.
		do
			Result := tokens.secondary
		end

	background: SV_COLOR
			-- Background color from current tokens.
		do
			Result := tokens.background
		end

	surface: SV_COLOR
			-- Surface color from current tokens.
		do
			Result := tokens.surface
		end

	error_color: SV_COLOR
			-- Error color from current tokens.
		do
			Result := tokens.error
		end

	text_primary: SV_COLOR
			-- Primary text color from current tokens.
		do
			Result := tokens.text_primary
		end

	text_secondary: SV_COLOR
			-- Secondary text color from current tokens.
		do
			Result := tokens.text_secondary
		end

	on_primary: SV_COLOR
			-- Color for content on primary background.
		do
			Result := tokens.on_primary
		end

	on_surface: SV_COLOR
			-- Color for content on surface.
		do
			Result := tokens.on_surface
		end

end
