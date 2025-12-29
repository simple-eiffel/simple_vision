note
	description: "Text label widget - wraps EV_LABEL"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TEXT

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
			-- Create empty text label.
		do
			create ev_label
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create text label with initial text.
		require
			text_not_void: a_text /= Void
		do
			create ev_label
			ev_label.set_text (a_text.to_string_32)
			apply_theme
			subscribe_to_theme
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Access

	ev_label: EV_LABEL
			-- Underlying EiffelVision-2 label.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_label
		end

	text: STRING_32
			-- Current text content.
		do
			Result := ev_label.text
		end

feature -- Text Update

	update_text (a_text: READABLE_STRING_GENERAL)
			-- Update label text (procedure for statement use).
		require
			text_not_void: a_text /= Void
		do
			ev_label.set_text (a_text.to_string_32)
		ensure
			text_set: text.same_string_general (a_text)
		end

feature -- Fluent Configuration

	set_text (a_text: READABLE_STRING_GENERAL): like Current
			-- Set label text (fluent).
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

feature -- Alignment

	align_left: like Current
			-- Align text to the left.
		do
			ev_label.align_text_left
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_center: like Current
			-- Center the text.
		do
			ev_label.align_text_center
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_right: like Current
			-- Align text to the right.
		do
			ev_label.align_text_right
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_top: like Current
			-- Align text to the top.
		do
			ev_label.align_text_top
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_vertical_center: like Current
			-- Vertically center the text.
		do
			ev_label.align_text_vertical_center
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_bottom: like Current
			-- Align text to the bottom.
		do
			ev_label.align_text_bottom
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Font

	set_font (a_font: EV_FONT): like Current
			-- Set label font.
		require
			font_attached: a_font /= Void
		do
			ev_label.set_font (a_font)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	bold: like Current
			-- Make text bold.
		local
			l_font: EV_FONT
		do
			l_font := ev_label.font.twin
			l_font.set_weight ({EV_FONT_CONSTANTS}.weight_bold)
			ev_label.set_font (l_font)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	italic: like Current
			-- Make text italic.
		local
			l_font: EV_FONT
		do
			l_font := ev_label.font.twin
			l_font.set_shape ({EV_FONT_CONSTANTS}.shape_italic)
			ev_label.set_font (l_font)
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
			l_font := ev_label.font.twin
			l_font.set_height_in_points (a_points)
			ev_label.set_font (l_font)
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
			ev_label.set_foreground_color (a_color)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	background (a_color: EV_COLOR): like Current
			-- Set text background color.
		require
			color_attached: a_color /= Void
		do
			ev_label.set_background_color (a_color)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled font to label.
		do
			ev_label.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_label.set_background_color (tokens.background.to_ev_color)
			ev_label.set_font (theme.scaled_font)
		end

invariant
	ev_label_exists: ev_label /= Void

end
