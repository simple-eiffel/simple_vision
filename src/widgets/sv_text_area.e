note
	description: "Multi-line read-only text area with word wrapping and scrollbars - wraps EV_TEXT"
	author: "Larry Rix"

class
	SV_TEXT_AREA

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_text

feature {NONE} -- Initialization

	make
			-- Create empty text area.
		do
			create ev_text
			ev_text.disable_edit
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create text area with initial content.
		require
			text_not_void: a_text /= Void
		do
			create ev_text
			ev_text.set_text (a_text.to_string_32)
			ev_text.disable_edit
			apply_theme
			subscribe_to_theme
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Access

	ev_text: EV_TEXT
			-- Underlying EiffelVision-2 multi-line text widget.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_text
		end

	text: STRING_32
			-- Current text content.
		do
			Result := ev_text.text
		end

feature -- Text Update

	update_text (a_text: READABLE_STRING_GENERAL)
			-- Update text content (procedure for statement use).
		require
			text_not_void: a_text /= Void
		do
			ev_text.set_text (a_text.to_string_32)
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Fluent Configuration

	set_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set text content (fluent).
		require
			text_not_void: a_text /= Void
		do
			update_text (a_text)
			Result := Current
		ensure
			text_set: text.same_string_general (a_text)
			result_is_current: Result = Current
		end

	content (a_text: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_text.
		require
			text_not_void: a_text /= Void
		do
			Result := set_text (a_text)
		ensure
			result_is_current: Result = Current
		end

	set_read_only: like Current
			-- Disable editing (default).
		do
			ev_text.disable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_editable: like Current
			-- Enable editing.
		do
			ev_text.enable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Font

	bold: like Current
			-- Make text bold.
		local
			l_font: EV_FONT
		do
			l_font := ev_text.font.twin
			l_font.set_weight ({EV_FONT_CONSTANTS}.weight_bold)
			ev_text.set_font (l_font)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	font_size (a_points: INTEGER): like Current
			-- Set font size in points.
		require
			positive_size: a_points > 0
		local
			l_font: EV_FONT
		do
			l_font := ev_text.font.twin
			l_font.set_height_in_points (a_points)
			ev_text.set_font (l_font)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Colors

	foreground (a_color: EV_COLOR): like Current
			-- Set text foreground color.
		require
			color_attached: a_color /= Void
		do
			ev_text.set_foreground_color (a_color)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	background (a_color: EV_COLOR): like Current
			-- Set text background color.
		require
			color_attached: a_color /= Void
		do
			ev_text.set_background_color (a_color)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled font.
		do
			ev_text.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_text.set_background_color (tokens.background.to_ev_color)
			ev_text.set_font (theme.scaled_font)
		end

invariant
	ev_text_exists: ev_text /= Void

end
