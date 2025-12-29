note
	description: "Message box dialogs - wraps EV_INFORMATION_DIALOG, EV_WARNING_DIALOG, etc."
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MESSAGE_BOX

inherit
	SV_ANY

create
	make_info,
	make_warning,
	make_error,
	make_question,
	make_confirm

feature {NONE} -- Initialization

	make_info (a_message: STRING)
			-- Create information dialog.
		require
			message_not_empty: not a_message.is_empty
		do
			create ev_info_dialog.make_with_text (a_message)
			dialog_type := Type_info
			message := a_message
		end

	make_warning (a_message: STRING)
			-- Create warning dialog.
		require
			message_not_empty: not a_message.is_empty
		do
			create ev_warning_dialog.make_with_text (a_message)
			dialog_type := Type_warning
			message := a_message
		end

	make_error (a_message: STRING)
			-- Create error dialog.
		require
			message_not_empty: not a_message.is_empty
		do
			create ev_error_dialog.make_with_text (a_message)
			dialog_type := Type_error
			message := a_message
		end

	make_question (a_message: STRING)
			-- Create question dialog (Yes/No).
		require
			message_not_empty: not a_message.is_empty
		do
			create ev_question_dialog.make_with_text (a_message)
			dialog_type := Type_question
			message := a_message
		end

	make_confirm (a_message: STRING)
			-- Create confirmation dialog (OK/Cancel).
		require
			message_not_empty: not a_message.is_empty
		do
			create ev_confirm_dialog.make_with_text (a_message)
			dialog_type := Type_confirm
			message := a_message
		end

feature -- Access

	ev_info_dialog: detachable EV_INFORMATION_DIALOG
	ev_warning_dialog: detachable EV_WARNING_DIALOG
	ev_error_dialog: detachable EV_ERROR_DIALOG
	ev_question_dialog: detachable EV_QUESTION_DIALOG
	ev_confirm_dialog: detachable EV_CONFIRMATION_DIALOG

	dialog_type: INTEGER
			-- Type of dialog.

	message: STRING
			-- Dialog message.

	Type_info: INTEGER = 1
	Type_warning: INTEGER = 2
	Type_error: INTEGER = 3
	Type_question: INTEGER = 4
	Type_confirm: INTEGER = 5

feature -- Result

	was_ok: BOOLEAN
			-- Was OK pressed? (for confirm dialog)

	was_yes: BOOLEAN
			-- Was Yes pressed? (for question dialog)

	was_no: BOOLEAN
			-- Was No pressed? (for question dialog)
		do
			Result := not was_yes
		end

	was_cancelled: BOOLEAN
			-- Was Cancel pressed? (for confirm dialog)
		do
			Result := not was_ok
		end

feature -- Configuration

	set_title (a_title: STRING)
			-- Set dialog title.
		require
			title_not_empty: not a_title.is_empty
		do
			inspect dialog_type
			when Type_info then
				check attached ev_info_dialog as d then d.set_title (a_title) end
			when Type_warning then
				check attached ev_warning_dialog as d then d.set_title (a_title) end
			when Type_error then
				check attached ev_error_dialog as d then d.set_title (a_title) end
			when Type_question then
				check attached ev_question_dialog as d then d.set_title (a_title) end
			when Type_confirm then
				check attached ev_confirm_dialog as d then d.set_title (a_title) end
			end
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

feature -- Display

	show (a_parent: SV_WINDOW)
			-- Show dialog modal to parent.
		require
			parent_attached: a_parent /= Void
		do
			inspect dialog_type
			when Type_info then
				check attached ev_info_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
				end
			when Type_warning then
				check attached ev_warning_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
				end
			when Type_error then
				check attached ev_error_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
				end
			when Type_question then
				check attached ev_question_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
					if attached d.selected_button as btn then
						was_yes := btn.same_string (d.ev_yes)
					end
				end
			when Type_confirm then
				check attached ev_confirm_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
					if attached d.selected_button as btn then
						was_ok := btn.same_string (d.ev_ok)
					end
				end
			end
		end

feature -- Convenience (class-level would be better but requires once)

	show_info (a_parent: SV_WINDOW; a_message: STRING)
			-- Show info message.
		require
			parent_attached: a_parent /= Void
			message_not_empty: not a_message.is_empty
		local
			l_dialog: EV_INFORMATION_DIALOG
		do
			create l_dialog.make_with_text (a_message)
			l_dialog.show_modal_to_window (a_parent.ev_titled_window)
		end

	show_warning (a_parent: SV_WINDOW; a_message: STRING)
			-- Show warning message.
		require
			parent_attached: a_parent /= Void
			message_not_empty: not a_message.is_empty
		local
			l_dialog: EV_WARNING_DIALOG
		do
			create l_dialog.make_with_text (a_message)
			l_dialog.show_modal_to_window (a_parent.ev_titled_window)
		end

	show_error (a_parent: SV_WINDOW; a_message: STRING)
			-- Show error message.
		require
			parent_attached: a_parent /= Void
			message_not_empty: not a_message.is_empty
		local
			l_dialog: EV_ERROR_DIALOG
		do
			create l_dialog.make_with_text (a_message)
			l_dialog.show_modal_to_window (a_parent.ev_titled_window)
		end

	ask_yes_no (a_parent: SV_WINDOW; a_message: STRING): BOOLEAN
			-- Ask yes/no question, return True if Yes.
		require
			parent_attached: a_parent /= Void
			message_not_empty: not a_message.is_empty
		local
			l_dialog: EV_QUESTION_DIALOG
		do
			create l_dialog.make_with_text (a_message)
			l_dialog.show_modal_to_window (a_parent.ev_titled_window)
			if attached l_dialog.selected_button as btn then
				Result := btn.same_string (l_dialog.ev_yes)
			end
		end

	ask_ok_cancel (a_parent: SV_WINDOW; a_message: STRING): BOOLEAN
			-- Ask OK/Cancel, return True if OK.
		require
			parent_attached: a_parent /= Void
			message_not_empty: not a_message.is_empty
		local
			l_dialog: EV_CONFIRMATION_DIALOG
		do
			create l_dialog.make_with_text (a_message)
			l_dialog.show_modal_to_window (a_parent.ev_titled_window)
			if attached l_dialog.selected_button as btn then
				Result := btn.same_string (l_dialog.ev_ok)
			end
		end

end
