note
	description: "Design tokens for simple_vision theming - semantic constants for visual properties"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TOKENS

create
	make

feature {NONE} -- Initialization

	make
			-- Create with default token values (Material Light-inspired).
		do
			initialize_colors
			initialize_typography
			initialize_spacing
			initialize_borders
		end

feature -- Colors (Semantic)

	primary: SV_COLOR
			-- Primary brand color.
		attribute
			create Result.make_from_hex ("#6750A4")
		end

	primary_variant: SV_COLOR
			-- Primary color variant (darker).
		attribute
			create Result.make_from_hex ("#4F378B")
		end

	secondary: SV_COLOR
			-- Secondary brand color.
		attribute
			create Result.make_from_hex ("#625B71")
		end

	secondary_variant: SV_COLOR
			-- Secondary color variant.
		attribute
			create Result.make_from_hex ("#4A4458")
		end

	tertiary: SV_COLOR
			-- Tertiary accent color.
		attribute
			create Result.make_from_hex ("#7D5260")
		end

	background: SV_COLOR
			-- Background color.
		attribute
			create Result.make_from_hex ("#FFFBFE")
		end

	surface: SV_COLOR
			-- Surface color (cards, panels).
		attribute
			create Result.make_from_hex ("#FFFBFE")
		end

	surface_variant: SV_COLOR
			-- Surface variant color.
		attribute
			create Result.make_from_hex ("#E7E0EC")
		end

	error: SV_COLOR
			-- Error state color.
		attribute
			create Result.make_from_hex ("#B3261E")
		end

	warning: SV_COLOR
			-- Warning state color.
		attribute
			create Result.make_from_hex ("#F9A825")
		end

	success: SV_COLOR
			-- Success state color.
		attribute
			create Result.make_from_hex ("#2E7D32")
		end

	info: SV_COLOR
			-- Info state color.
		attribute
			create Result.make_from_hex ("#0288D1")
		end

	on_primary: SV_COLOR
			-- Text/icon color on primary background.
		attribute
			create Result.make_from_hex ("#FFFFFF")
		end

	on_secondary: SV_COLOR
			-- Text/icon color on secondary background.
		attribute
			create Result.make_from_hex ("#FFFFFF")
		end

	on_background: SV_COLOR
			-- Text/icon color on background.
		attribute
			create Result.make_from_hex ("#1C1B1F")
		end

	on_surface: SV_COLOR
			-- Text/icon color on surface.
		attribute
			create Result.make_from_hex ("#1C1B1F")
		end

	on_error: SV_COLOR
			-- Text/icon color on error background.
		attribute
			create Result.make_from_hex ("#FFFFFF")
		end

	text_primary: SV_COLOR
			-- Primary text color.
		attribute
			create Result.make_from_hex ("#1C1B1F")
		end

	text_secondary: SV_COLOR
			-- Secondary text color.
		attribute
			create Result.make_from_hex ("#49454F")
		end

	text_disabled: SV_COLOR
			-- Disabled text color (38 percent opacity).
		attribute
			create Result.make_rgba (28, 27, 31, 97)
		end

	text_hint: SV_COLOR
			-- Hint/placeholder text color.
		attribute
			create Result.make_from_hex ("#79747E")
		end

	border: SV_COLOR
			-- Border color.
		attribute
			create Result.make_from_hex ("#79747E")
		end

	divider: SV_COLOR
			-- Divider line color.
		attribute
			create Result.make_from_hex ("#CAC4D0")
		end

feature -- Typography

	font_family: STRING
			-- Primary font family.
		attribute
			Result := "Segoe UI"
		end

	font_family_mono: STRING
			-- Monospace font family.
		attribute
			Result := "Consolas"
		end

	font_size_xs: INTEGER = 10
			-- Extra small font size.

	font_size_sm: INTEGER = 12
			-- Small font size.

	font_size_md: INTEGER = 14
			-- Medium font size (default).

	font_size_lg: INTEGER = 16
			-- Large font size.

	font_size_xl: INTEGER = 20
			-- Extra large font size.

	font_size_2xl: INTEGER = 24
			-- 2x large font size.

	font_size_3xl: INTEGER = 32
			-- 3x large font size.

	font_weight_normal: INTEGER = 400
			-- Normal font weight.

	font_weight_medium: INTEGER = 500
			-- Medium font weight.

	font_weight_bold: INTEGER = 700
			-- Bold font weight.

	line_height_tight: REAL = 1.25
			-- Tight line height.

	line_height_normal: REAL = 1.5
			-- Normal line height.

	line_height_relaxed: REAL = 1.75
			-- Relaxed line height.

feature -- Spacing

	space_xs: INTEGER = 4
			-- Extra small spacing.

	space_sm: INTEGER = 8
			-- Small spacing.

	space_md: INTEGER = 16
			-- Medium spacing.

	space_lg: INTEGER = 24
			-- Large spacing.

	space_xl: INTEGER = 32
			-- Extra large spacing.

	space_2xl: INTEGER = 48
			-- 2x large spacing.

feature -- Borders

	border_radius_none: INTEGER = 0
			-- No border radius.

	border_radius_sm: INTEGER = 4
			-- Small border radius.

	border_radius_md: INTEGER = 8
			-- Medium border radius.

	border_radius_lg: INTEGER = 16
			-- Large border radius.

	border_radius_full: INTEGER = 9999
			-- Full/circular border radius.

	border_width_thin: INTEGER = 1
			-- Thin border width.

	border_width_medium: INTEGER = 2
			-- Medium border width.

	border_width_thick: INTEGER = 4
			-- Thick border width.

feature -- Animation Durations (milliseconds)

	duration_fast: INTEGER = 150
			-- Fast animation duration.

	duration_normal: INTEGER = 300
			-- Normal animation duration.

	duration_slow: INTEGER = 500
			-- Slow animation duration.

feature -- Element Modification

	set_primary (a_color: SV_COLOR)
			-- Set primary color.
		do
			primary := a_color
		ensure
			primary_set: primary = a_color
		end

	set_secondary (a_color: SV_COLOR)
			-- Set secondary color.
		do
			secondary := a_color
		ensure
			secondary_set: secondary = a_color
		end

	set_background (a_color: SV_COLOR)
			-- Set background color.
		do
			background := a_color
		ensure
			background_set: background = a_color
		end

	set_surface (a_color: SV_COLOR)
			-- Set surface color.
		do
			surface := a_color
		ensure
			surface_set: surface = a_color
		end

	set_error (a_color: SV_COLOR)
			-- Set error color.
		do
			error := a_color
		ensure
			error_set: error = a_color
		end

	set_font_family (a_font: STRING)
			-- Set primary font family.
		require
			font_valid: a_font /= Void and then not a_font.is_empty
		do
			font_family := a_font
		ensure
			font_set: font_family.same_string (a_font)
		end

	set_on_primary (a_color: SV_COLOR)
			-- Set on-primary color.
		do
			on_primary := a_color
		end

	set_on_secondary (a_color: SV_COLOR)
			-- Set on-secondary color.
		do
			on_secondary := a_color
		end

	set_on_background (a_color: SV_COLOR)
			-- Set on-background color.
		do
			on_background := a_color
		end

	set_on_surface (a_color: SV_COLOR)
			-- Set on-surface color.
		do
			on_surface := a_color
		end

	set_on_error (a_color: SV_COLOR)
			-- Set on-error color.
		do
			on_error := a_color
		end

	set_text_primary (a_color: SV_COLOR)
			-- Set text primary color.
		do
			text_primary := a_color
		end

	set_text_secondary (a_color: SV_COLOR)
			-- Set text secondary color.
		do
			text_secondary := a_color
		end

	set_text_hint (a_color: SV_COLOR)
			-- Set text hint color.
		do
			text_hint := a_color
		end

	set_border (a_color: SV_COLOR)
			-- Set border color.
		do
			border := a_color
		end

	set_divider (a_color: SV_COLOR)
			-- Set divider color.
		do
			divider := a_color
		end

	set_surface_variant (a_color: SV_COLOR)
			-- Set surface variant color.
		do
			surface_variant := a_color
		end

	set_success (a_color: SV_COLOR)
			-- Set success color.
		do
			success := a_color
		end

	set_warning (a_color: SV_COLOR)
			-- Set warning color.
		do
			warning := a_color
		end

	set_info (a_color: SV_COLOR)
			-- Set info color.
		do
			info := a_color
		end

feature {NONE} -- Initialization Helpers

	initialize_colors
			-- Initialize color tokens.
		do
			-- Colors are initialized via attribute defaults
		end

	initialize_typography
			-- Initialize typography tokens.
		do
			-- Typography values are constants
		end

	initialize_spacing
			-- Initialize spacing tokens.
		do
			-- Spacing values are constants
		end

	initialize_borders
			-- Initialize border tokens.
		do
			-- Border values are constants
		end

end
