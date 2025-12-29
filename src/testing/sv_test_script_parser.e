note
	description: "Parser for JSON test scripts"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TEST_SCRIPT_PARSER

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create parser.
		do
			create last_error.make_empty
		end

feature -- Access

	last_error: STRING
			-- Last parsing error.

feature -- Parsing

	parse (a_json: STRING): ARRAYED_LIST [SV_TEST_STEP]
			-- Parse JSON script into steps.
			-- Simple parser - expects our specific JSON format.
		local
			l_pos, l_end: INTEGER
			l_step_json: STRING
		do
			create Result.make (20)
			last_error.wipe_out

			-- Find "steps" array
			l_pos := a_json.substring_index ("%"steps%"", 1)
			if l_pos = 0 then
				last_error := "No 'steps' array found"
			else
				-- Find opening bracket of steps array
				l_pos := a_json.index_of ('[', l_pos)
				if l_pos > 0 then
					-- Parse each step object
					from
						l_pos := a_json.index_of ('{', l_pos)
					until
						l_pos = 0
					loop
						l_end := a_json.index_of ('}', l_pos)
						if l_end > 0 then
							l_step_json := a_json.substring (l_pos, l_end)
							if attached parse_step (l_step_json) as step then
								Result.extend (step)
							end
							l_pos := a_json.index_of ('{', l_end)
						else
							l_pos := 0
						end
					end
				end
			end

			debug_log ("Parsed " + Result.count.out + " steps")
		end

	parse_step (a_json: STRING): detachable SV_TEST_STEP
			-- Parse single step from JSON object.
		local
			l_action, l_target, l_value: STRING
			l_wait_ms, l_repeat: INTEGER
		do
			l_action := extract_string_value (a_json, "action")
			l_target := extract_string_value (a_json, "target")
			l_value := extract_string_value (a_json, "value")
			l_wait_ms := extract_integer_value (a_json, "milliseconds")
			l_repeat := extract_integer_value (a_json, "repeat")

			if not l_action.is_empty then
				create Result.make (l_action, l_target, l_value, l_wait_ms)
				if l_repeat > 0 then
					Result.set_repeat (l_repeat)
				end
				if attached extract_string_value (a_json, "description") as desc and then not desc.is_empty then
					Result.set_description (desc)
				end
			end
		end

feature {NONE} -- Implementation

	extract_string_value (a_json, a_key: STRING): STRING
			-- Extract string value for key from JSON.
		local
			l_pos, l_start, l_end: INTEGER
			l_search: STRING
		do
			create Result.make_empty
			l_search := "%"" + a_key + "%": %""
			l_pos := a_json.substring_index (l_search, 1)
			if l_pos > 0 then
				l_start := l_pos + l_search.count
				l_end := a_json.index_of ('"', l_start)
				if l_end > l_start then
					Result := a_json.substring (l_start, l_end - 1)
				end
			end
		end

	extract_integer_value (a_json, a_key: STRING): INTEGER
			-- Extract integer value for key from JSON.
		local
			l_pos, l_start, l_end: INTEGER
			l_search, l_num: STRING
		do
			l_search := "%"" + a_key + "%": "
			l_pos := a_json.substring_index (l_search, 1)
			if l_pos > 0 then
				l_start := l_pos + l_search.count
				-- Find end of number (comma, space, or closing brace)
				from l_end := l_start until l_end > a_json.count or else not a_json.item (l_end).is_digit loop
					l_end := l_end + 1
				end
				if l_end > l_start then
					l_num := a_json.substring (l_start, l_end - 1)
					if l_num.is_integer then
						Result := l_num.to_integer
					end
				end
			end
		end

end
