note
	description: "Application wrapper - entry point for simple_vision apps"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_APPLICATION

inherit
	SV_ANY

create
	make,
	make_and_launch

feature {NONE} -- Initialization

	make
			-- Create application.
		do
			create ev_application
			create windows.make (5)
		end

	make_and_launch (a_main_window_builder: FUNCTION [SV_WINDOW])
			-- Create application, build main window, and launch.
		require
			builder_attached: a_main_window_builder /= Void
		local
			l_window: SV_WINDOW
		do
			make
			l_window := a_main_window_builder.item (Void)
			add_window (l_window)
			l_window.show_now
			launch
		end

feature -- Access

	ev_application: EV_APPLICATION
			-- Underlying EiffelVision-2 application.

	windows: ARRAYED_LIST [SV_WINDOW]
			-- Registered windows.

	main_window: detachable SV_WINDOW
			-- Primary window (first registered).
		do
			if not windows.is_empty then
				Result := windows.first
			end
		end

feature -- Window Management

	add_window (a_window: SV_WINDOW)
			-- Register a window with the application.
		require
			window_attached: a_window /= Void
		do
			windows.extend (a_window)
			a_window.set_application (Current)
		ensure
			window_added: windows.has (a_window)
		end

	remove_window (a_window: SV_WINDOW)
			-- Unregister a window.
		require
			window_attached: a_window /= Void
		do
			windows.prune_all (a_window)
		ensure
			window_removed: not windows.has (a_window)
		end

feature -- Execution

	launch
			-- Start the application event loop.
		require
			has_windows: not windows.is_empty
		do
			debug_log ("Launching application with " + windows.count.out + " window(s)")
			ev_application.launch
		end

	quit
			-- Terminate the application.
		do
			debug_log ("Quitting application")
			ev_application.destroy
		end

	process_events
			-- Process pending events.
		do
			ev_application.process_events
		end

feature -- Status

	is_launched: BOOLEAN
			-- Has the application been launched?
		do
			Result := ev_application.is_launched
		end

invariant
	ev_application_exists: ev_application /= Void
	windows_exists: windows /= Void

end
