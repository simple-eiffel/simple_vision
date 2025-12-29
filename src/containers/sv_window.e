note
	description: "Window container - wraps EV_TITLED_WINDOW"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_WINDOW

inherit
	SV_CONTAINER
		redefine
			show,
			show_now,
			apply_theme
		end

create
	make,
	make_with_title

feature {NONE} -- Initialization

	make
			-- Create window with default title.
		do
			make_with_title ("simple_vision")
		end

	make_with_title (a_title: READABLE_STRING_GENERAL)
			-- Create window with specified title.
		require
			title_not_empty: not a_title.is_empty
		do
			create ev_titled_window
			ev_titled_window.set_title (a_title.to_string_32)
			ev_titled_window.close_request_actions.extend (agent handle_close_request)
			apply_theme
			subscribe_to_theme
		ensure
			title_set: title.same_string_general (a_title)
		end

feature -- Access

	ev_titled_window: EV_TITLED_WINDOW
			-- Underlying EiffelVision-2 titled window.

	ev_container: EV_CONTAINER
			-- Implement SV_CONTAINER requirement.
		do
			Result := ev_titled_window
		end

	application: detachable SV_APPLICATION
			-- Owning application.

	title: STRING_32
			-- Window title.
		do
			Result := ev_titled_window.title
		end

feature -- Fluent Configuration

	set_title (a_title: READABLE_STRING_GENERAL): like Current
			-- Set window title.
		require
			title_not_empty: not a_title.is_empty
		do
			ev_titled_window.set_title (a_title.to_string_32)
			Result := Current
		ensure
			title_set: title.same_string_general (a_title)
			result_is_current: Result = Current
		end

	titled (a_title: READABLE_STRING_GENERAL): like Current
			-- Fluent alias for set_title.
		require
			title_not_empty: not a_title.is_empty
		do
			Result := set_title (a_title)
		ensure
			result_is_current: Result = Current
		end

	set_size (a_width, a_height: INTEGER): like Current
			-- Set window size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			ev_titled_window.set_size (a_width, a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	size (a_width, a_height: INTEGER): like Current
			-- Fluent alias for set_size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			Result := set_size (a_width, a_height)
		ensure
			result_is_current: Result = Current
		end

	set_position (a_x, a_y: INTEGER): like Current
			-- Set window position.
		do
			ev_titled_window.set_position (a_x, a_y)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	position (a_x, a_y: INTEGER): like Current
			-- Fluent alias for set_position.
		do
			Result := set_position (a_x, a_y)
		ensure
			result_is_current: Result = Current
		end

	centered: like Current
			-- Center window on screen.
		local
			l_screen: EV_SCREEN
			l_x, l_y: INTEGER
		do
			create l_screen
			l_x := (l_screen.width - ev_titled_window.width) // 2
			l_y := (l_screen.height - ev_titled_window.height) // 2
			ev_titled_window.set_position (l_x.max (0), l_y.max (0))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	maximized: like Current
			-- Maximize window.
		do
			ev_titled_window.maximize
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	minimized: like Current
			-- Minimize window.
		do
			ev_titled_window.minimize
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Content

	content (a_widget: SV_WIDGET): like Current
			-- Set the window's single child content.
		require
			widget_attached: a_widget /= Void
		do
			ev_titled_window.wipe_out
			ev_titled_window.extend (a_widget.ev_widget)
			Result := Current
		ensure
			has_content: children_count = 1
			result_is_current: Result = Current
		end

	content_ev (a_widget: EV_WIDGET): like Current
			-- Set content with raw EV widget.
		require
			widget_attached: a_widget /= Void
		do
			ev_titled_window.wipe_out
			ev_titled_window.extend (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Visibility

	show_now
			-- Show the window (procedure for statement use).
		do
			ev_titled_window.show
		end

	show: like Current
			-- Show the window (fluent).
		do
			show_now
			Result := Current
		ensure then
			result_is_current: Result = Current
		end

	show_modal_to (a_parent: SV_WINDOW): like Current
			-- Show as modal dialog to parent.
		require
			parent_attached: a_parent /= Void
		do
			ev_titled_window.show_relative_to_window (a_parent.ev_titled_window)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	close
			-- Close the window.
		do
			ev_titled_window.destroy
		end

feature -- Events

	on_close (a_action: PROCEDURE)
			-- Set action to execute when window closes.
		require
			action_attached: a_action /= Void
		do
			close_action := a_action
		ensure
			action_set: close_action = a_action
		end

	on_resize (a_action: PROCEDURE [INTEGER, INTEGER])
			-- Set action to execute when window resizes.
			-- Action receives new width and height.
		require
			action_attached: a_action /= Void
		do
			ev_titled_window.resize_actions.extend (agent (x, y, w, h: INTEGER; act: PROCEDURE [INTEGER, INTEGER])
				do
					act.call ([w, h])
				end (?, ?, ?, ?, a_action))
		end

feature {SV_APPLICATION} -- Application Link

	set_application (a_app: SV_APPLICATION)
			-- Link this window to an application.
		require
			app_attached: a_app /= Void
		do
			application := a_app
		ensure
			application_set: application = a_app
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to window.
		do
			ev_titled_window.set_background_color (tokens.background.to_ev_color)
		end

feature {NONE} -- Implementation

	close_action: detachable PROCEDURE
			-- Action to execute on close.

	handle_close_request
			-- Handle window close request.
		do
			if attached close_action as act then
				act.call (Void)
			end
			if attached application as app then
				app.remove_window (Current)
				if app.windows.is_empty then
					app.quit
				end
			end
			ev_titled_window.destroy
		end

invariant
	ev_titled_window_exists: ev_titled_window /= Void

end
