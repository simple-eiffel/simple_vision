note
	description: "Status bar widget - wraps EV_STATUS_BAR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_STATUSBAR

inherit
	SV_WIDGET

create
	make,
	make_with_text

feature {NONE} -- Initialization

	make
			-- Create empty status bar.
		do
			create ev_status_bar
		end

	make_with_text (a_text: STRING)
			-- Create status bar with initial text.
		require
			text_not_void: a_text /= Void
		do
			create ev_status_bar
			set_text (a_text)
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
			if ev_status_bar.count > 0 and then attached {EV_LABEL} ev_status_bar.i_th (1) as l_label then
				Result := l_label.text
			else
				Result := ""
			end
		end

feature -- Text Operations

	set_text (a_text: STRING)
			-- Set status text.
		require
			text_not_void: a_text /= Void
		local
			l_label: EV_LABEL
		do
			ev_status_bar.wipe_out
			create l_label.make_with_text (a_text)
			ev_status_bar.extend (l_label)
		end

	content (a_text: STRING): like Current
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

	message (a_text: STRING)
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

	error (a_message: STRING)
			-- Display error message.
		require
			message_not_empty: not a_message.is_empty
		do
			set_text ("Error: " + a_message)
		end

invariant
	ev_status_bar_exists: ev_status_bar /= Void

end
