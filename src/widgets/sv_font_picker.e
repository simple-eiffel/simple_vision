note
	description: "Font picker dialog - wraps EV_FONT_DIALOG"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_FONT_PICKER

inherit
	SV_ANY

create
	make,
	make_with_font

feature {NONE} -- Initialization

	make
			-- Create font picker with default font.
		do
			create ev_font_dialog
			create selected_font
		end

	make_with_font (a_font: EV_FONT)
			-- Create font picker with initial font.
		require
			font_attached: a_font /= Void
		do
			create ev_font_dialog
			ev_font_dialog.set_font (a_font)
			selected_font := a_font.twin
		end

feature -- Access

	ev_font_dialog: EV_FONT_DIALOG
			-- Underlying EiffelVision-2 font dialog.

	selected_font: EV_FONT
			-- Currently selected font.

	family: STRING_32
			-- Font family name.
		do
			Result := selected_font.name
		end

	height: INTEGER
			-- Font height in points.
		do
			Result := selected_font.height
		end

	is_bold: BOOLEAN
			-- Is font bold?
		do
			Result := selected_font.weight = {EV_FONT_CONSTANTS}.weight_bold
		end

	is_italic: BOOLEAN
			-- Is font italic?
		do
			Result := selected_font.shape = {EV_FONT_CONSTANTS}.shape_italic
		end

	font_description: STRING
			-- Human-readable font description.
		do
			Result := family.to_string_8 + " " + height.out
			if is_bold then
				Result := Result + " Bold"
			end
			if is_italic then
				Result := Result + " Italic"
			end
		end

	was_selected: BOOLEAN
			-- Was a font selected (not cancelled)?

feature -- Configuration

	set_title (a_title: STRING)
			-- Set dialog title.
		require
			title_not_empty: not a_title.is_empty
		do
			ev_font_dialog.set_title (a_title)
		end

	title (a_title: STRING): like Current
			-- Set title (fluent).
		require
			title_not_empty: not a_title.is_empty
		do
			set_title (a_title)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_font (a_font: EV_FONT)
			-- Set initial font.
		require
			font_attached: a_font /= Void
		do
			ev_font_dialog.set_font (a_font)
			selected_font := a_font.twin
		end

	set_family (a_family: STRING)
			-- Set font family.
		require
			family_not_empty: not a_family.is_empty
		do
			selected_font.set_family ({EV_FONT_CONSTANTS}.family_sans)
			selected_font.preferred_families.wipe_out
			selected_font.preferred_families.extend (a_family)
			ev_font_dialog.set_font (selected_font)
		end

	set_height (a_height: INTEGER)
			-- Set font height.
		require
			positive: a_height > 0
		do
			selected_font.set_height (a_height)
			ev_font_dialog.set_font (selected_font)
		end

	initial_family (a_family: STRING): like Current
			-- Set initial family (fluent).
		require
			family_not_empty: not a_family.is_empty
		do
			set_family (a_family)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	initial_height (a_height: INTEGER): like Current
			-- Set initial height (fluent).
		require
			positive: a_height > 0
		do
			set_height (a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Display

	show (a_parent: SV_WINDOW)
			-- Show font picker modal to parent.
		require
			parent_attached: a_parent /= Void
		local
			l_old_font: EV_FONT
		do
			l_old_font := selected_font.twin
			ev_font_dialog.show_modal_to_window (a_parent.ev_titled_window)
			selected_font := ev_font_dialog.font
			was_selected := not selected_font.is_equal (l_old_font)
		end

	show_and_get_font (a_parent: SV_WINDOW): EV_FONT
			-- Show picker and return selected font.
		require
			parent_attached: a_parent /= Void
		do
			show (a_parent)
			Result := selected_font
		end

invariant
	ev_font_dialog_exists: ev_font_dialog /= Void
	selected_font_exists: selected_font /= Void

end
