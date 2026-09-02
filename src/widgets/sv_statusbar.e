note
	description: "Status bar widget - wraps EV_STATUS_BAR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_STATUSBAR

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
			-- Create empty status bar.
		do
			create ev_status_bar
			apply_theme
			subscribe_to_theme
		end

	make_with_text (a_text: READABLE_STRING_GENERAL)
			-- Create status bar with initial text.
		require
			text_not_void: a_text /= Void
		do
			create ev_status_bar
			set_text (a_text)
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_status_bar: EV_STATUS_BAR
			-- Underlying EiffelVision-2 status bar.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_status_bar
		end

	text: STRING_32
			-- Current status text.
		do
			if ev_status_bar.count > 0 and then attached {EV_LABEL} ev_status_bar.i_th (1) as al_label then
				Result := al_label.text
			else
				Result := {STRING_32} ""
			end
		end

feature -- Text Operations

	set_text (a_text: READABLE_STRING_GENERAL)
			-- Set status text.
		require
			text_not_void: a_text /= Void
		local
			l_label: EV_LABEL
		do
			ev_status_bar.wipe_out
			create l_label.make_with_text (a_text.to_string_32)
			l_label.set_font (theme.scaled_font)
			l_label.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_status_bar.extend (l_label)
		end

	content (a_text: READABLE_STRING_GENERAL): like Current
			-- Set status text (fluent).
		require
			text_not_void: a_text /= Void
		do
			set_text (a_text)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear
			-- Clear status text.
		do
			set_text ("")
		end

	message (a_text: READABLE_STRING_GENERAL)
			-- Display a message (alias for set_text).
		require
			text_not_void: a_text /= Void
		do
			set_text (a_text)
		end

feature -- Ready Message

	ready
			-- Display "Ready" message.
		do
			set_text ("Ready")
		end

	working
			-- Display "Working..." message.
		do
			set_text ("Working...")
		end

	done
			-- Display "Done" message.
		do
			set_text ("Done")
		end

	error (a_message: READABLE_STRING_GENERAL)
			-- Display error message.
		require
			message_not_empty: not a_message.is_empty
		do
			set_text ({STRING_32} "Error: " + a_message.to_string_32)
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and font to status bar.
		do
			ev_status_bar.set_background_color (tokens.surface.to_ev_color)
			-- Reapply font to any existing labels
			across ev_status_bar as ic_item loop
				if attached {EV_LABEL} ic_item.item as al_label then
					al_label.set_font (theme.scaled_font)
					al_label.set_foreground_color (tokens.text_primary.to_ev_color)
				end
			end
		end

invariant
	ev_status_bar_exists: ev_status_bar /= Void

end
