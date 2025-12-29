note
	description: "Base class for all simple_vision classes"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SV_ANY

feature -- Constants

	Sv_version: STRING = "0.1.0"
			-- Library version.

feature -- Theme Access

	theme: SV_THEME
			-- Shared theme instance.
		once
			create Result.make_internal
		end

	tokens: SV_TOKENS
			-- Current design tokens (shortcut).
		do
			Result := theme.tokens
		end

feature -- Status

	is_debug_mode: BOOLEAN
			-- Is debug mode enabled?
		do
			Result := debug_mode_cell.item
		end

feature -- Settings

	enable_debug_mode
			-- Enable debug output.
		do
			debug_mode_cell.put (True)
		ensure
			enabled: is_debug_mode
		end

	disable_debug_mode
			-- Disable debug output.
		do
			debug_mode_cell.put (False)
		ensure
			disabled: not is_debug_mode
		end

feature {NONE} -- Implementation

	debug_mode_cell: CELL [BOOLEAN]
			-- Shared debug mode flag.
		once
			create Result.put (False)
		end

	debug_log (a_message: READABLE_STRING_GENERAL)
			-- Log debug message if debug mode enabled.
		do
			if is_debug_mode then
				print ("[SV] " + a_message.to_string_8 + "%N")
			end
		end

end
