note
	description: "Dialog widget - wraps EV_DIALOG"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_DIALOG

inherit
	SV_WIDGET
		redefine
			show,
			hide,
			set_minimum_size
		end

create
	make,
	make_with_title

feature {NONE} -- Initialization

	make
			-- Create dialog with no title.
		do
			create ev_dialog
		end

	make_with_title (a_title: STRING)
			-- Create dialog with title.
		require
			title_not_empty: not a_title.is_empty
		do
			create ev_dialog
			ev_dialog.set_title (a_title)
		end

feature -- Access

	ev_dialog: EV_DIALOG
			-- Underlying EiffelVision-2 dialog.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_dialog
		end

	title: STRING_32
			-- Dialog title.
		do
			Result := ev_dialog.title
		end

feature -- Title

	set_title (a_title: STRING)
			-- Set dialog title.
		require
			title_not_empty: not a_title.is_empty
		do
			ev_dialog.set_title (a_title)
		end

	titled (a_title: STRING): like Current
			-- Set title (fluent).
		require
			title_not_empty: not a_title.is_empty
		do
			set_title (a_title)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Content

	set_content (a_widget: SV_WIDGET)
			-- Set dialog content.
		require
			widget_attached: a_widget /= Void
		do
			ev_dialog.extend (a_widget.ev_widget)
		end

	content (a_widget: SV_WIDGET): like Current
			-- Set content (fluent).
		require
			widget_attached: a_widget /= Void
		do
			set_content (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Size

	set_size (a_width, a_height: INTEGER)
			-- Set dialog size.
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		do
			ev_dialog.set_size (a_width, a_height)
		end

	sized (a_width, a_height: INTEGER): like Current
			-- Set size (fluent).
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		do
			set_size (a_width, a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_minimum_size (a_width, a_height: INTEGER): like Current
			-- Set minimum size.
		do
			ev_dialog.set_minimum_size (a_width, a_height)
			Result := Current
		end

feature -- Modality

	show_modal (a_parent: SV_WINDOW)
			-- Show dialog modally relative to parent.
		require
			parent_attached: a_parent /= Void
		do
			ev_dialog.show_modal_to_window (a_parent.ev_titled_window)
		end

	show: like Current
			-- Show dialog non-modally.
		do
			ev_dialog.show
			Result := Current
		end

	hide: like Current
			-- Hide dialog.
		do
			ev_dialog.hide
			Result := Current
		end

	close
			-- Close and destroy dialog.
		do
			ev_dialog.destroy
		end

feature -- Result

	is_confirmed: BOOLEAN
			-- Was dialog confirmed (OK pressed)?

	confirm
			-- Mark as confirmed and close.
		do
			is_confirmed := True
			close
		end

	cancel
			-- Mark as cancelled and close.
		do
			is_confirmed := False
			close
		end

feature -- Standard Dialogs

	add_ok_button (a_action: detachable PROCEDURE)
			-- Add OK button.
		local
			l_btn: EV_BUTTON
		do
			create l_btn.make_with_text ("OK")
			l_btn.select_actions.extend (agent confirm)
			if attached a_action as act then
				l_btn.select_actions.extend (act)
			end
			ev_dialog.extend (l_btn)
		end

	add_cancel_button
			-- Add Cancel button.
		local
			l_btn: EV_BUTTON
		do
			create l_btn.make_with_text ("Cancel")
			l_btn.select_actions.extend (agent cancel)
			ev_dialog.extend (l_btn)
		end

	add_ok_cancel_buttons (a_ok_action: detachable PROCEDURE)
			-- Add OK and Cancel buttons.
		do
			add_ok_button (a_ok_action)
			add_cancel_button
		end

feature -- Events

	on_close (a_action: PROCEDURE)
			-- Set action for close.
		require
			action_attached: a_action /= Void
		do
			ev_dialog.close_request_actions.extend (a_action)
		end

invariant
	ev_dialog_exists: ev_dialog /= Void

end
