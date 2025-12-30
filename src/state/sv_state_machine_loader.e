note
	description: "Load state machine definitions from JSON (for dev/test scenarios)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"
	design_note: "[
		This loader is for:
		- Development/prototyping: Quick iteration on state machine designs
		- Test harness: Loading test scenarios from JSON fixtures
		- Code generation input: JSON specs that get compiled into Eiffel code

		Production binaries should have state machines defined in Eiffel code,
		not loaded from external files at runtime.
	]"

class
	SV_STATE_MACHINE_LOADER

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create loader.
		do
			last_error := ""
			create json_parser
		end

feature -- Loading

	load_from_json (a_json: STRING): detachable SV_STATE_MACHINE
			-- Parse JSON and create state machine.
			-- Returns Void on parse error (check last_error).
			--
			-- Expected JSON format:
			-- {
			--   "name": "app_states",
			--   "initial": "idle",
			--   "states": [
			--     { "name": "idle", "description": "Waiting for input" },
			--     { "name": "loading", "description": "Loading data" },
			--     { "name": "ready", "description": "Ready to process" },
			--     { "name": "error", "description": "Error occurred" }
			--   ],
			--   "transitions": [
			--     { "event": "start", "from": "idle", "to": "loading" },
			--     { "event": "loaded", "from": "loading", "to": "ready" },
			--     { "event": "fail", "from": "loading", "to": "error" },
			--     { "event": "retry", "from": "error", "to": "loading" },
			--     { "event": "reset", "from": "*", "to": "idle" }
			--   ]
			-- }
			--
			-- Note: "from": "*" means transition from ANY state.
		local
			l_parsed: detachable SIMPLE_JSON_VALUE
			l_machine: SV_STATE_MACHINE
			l_name, l_initial: STRING
		do
			last_error := ""
			l_parsed := json_parser.parse (a_json)

			if attached l_parsed and then l_parsed.is_object then
				-- Get root object
				if attached l_parsed.as_object as obj then
					-- Get name
					if attached obj.string_item ("name") as jname then
						l_name := jname.to_string_8
					else
						l_name := "unnamed"
					end

					create l_machine.make (l_name)

					-- Load states
					if attached obj.array_item ("states") as states_arr then
						load_states (l_machine, states_arr)
					end

					-- Set initial state
					if attached obj.string_item ("initial") as jinit then
						l_initial := jinit.to_string_8
						if l_machine.has_state (l_initial) then
							l_machine.set_initial (l_initial)
						else
							last_error := "Initial state '" + l_initial + "' not found"
						end
					end

					-- Load transitions
					if attached obj.array_item ("transitions") as trans_arr then
						load_transitions (l_machine, trans_arr)
					end

					if last_error.is_empty then
						Result := l_machine
					end
				end
			else
				if json_parser.has_errors then
					last_error := json_parser.errors_as_string.to_string_8
				else
					last_error := "Invalid JSON"
				end
			end
		end

	load_from_file (a_path: STRING): detachable SV_STATE_MACHINE
			-- Load state machine from JSON file.
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
		do
			create l_file.make_with_name (a_path)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				l_file.read_stream (l_file.count)
				l_content := l_file.last_string
				l_file.close
				Result := load_from_json (l_content)
			else
				last_error := "Cannot read file: " + a_path
			end
		end

feature -- Status

	last_error: STRING
			-- Error message from last load attempt.

	has_error: BOOLEAN
			-- Did last load have an error?
		do
			Result := not last_error.is_empty
		end

feature {NONE} -- Implementation

	json_parser: SIMPLE_JSON
			-- JSON parser instance.

	load_states (a_machine: SV_STATE_MACHINE; a_states: SIMPLE_JSON_ARRAY)
			-- Load states from JSON array.
		local
			l_state: SV_STATE
			l_name: STRING
			i: INTEGER
		do
			from
				i := 1
			until
				i > a_states.count
			loop
				if attached a_states.object_item (i) as state_obj then
					if attached state_obj.string_item ("name") as jname then
						l_name := jname.to_string_8
						l_state := a_machine.state (l_name)

						-- Optional description
						if attached state_obj.string_item ("description") as jdesc then
							l_state.set_description (jdesc.to_string_8)
						end
					end
				end
				i := i + 1
			end
		end

	load_transitions (a_machine: SV_STATE_MACHINE; a_transitions: SIMPLE_JSON_ARRAY)
			-- Load transitions from JSON array.
		local
			l_event, l_from, l_to: STRING
			l_transition: SV_TRANSITION
			i: INTEGER
		do
			from
				i := 1
			until
				i > a_transitions.count
			loop
				if attached a_transitions.object_item (i) as trans_obj then
					if attached trans_obj.string_item ("event") as jevent and then
					   attached trans_obj.string_item ("from") as jfrom and then
					   attached trans_obj.string_item ("to") as jto then
						l_event := jevent.to_string_8
						l_from := jfrom.to_string_8
						l_to := jto.to_string_8

						-- Handle wildcard "from": "*" means from any state
						if l_from.same_string ("*") then
							-- Create transition from every state
							across a_machine.all_state_names as state_name loop
								if a_machine.has_state (l_to) then
									create l_transition.make (l_event, state_name.item, l_to)
									a_machine.add_transition (l_transition)
								end
							end
						else
							-- Normal single transition
							if a_machine.has_state (l_from) and a_machine.has_state (l_to) then
								create l_transition.make (l_event, l_from, l_to)

								-- Optional description
								if attached trans_obj.string_item ("description") as jdesc then
									l_transition.set_description (jdesc.to_string_8)
								end

								a_machine.add_transition (l_transition)
							else
								if not a_machine.has_state (l_from) then
									last_error := "Unknown state: " + l_from
								end
								if not a_machine.has_state (l_to) then
									last_error := "Unknown state: " + l_to
								end
							end
						end
					end
				end
				i := i + 1
			end
		end

end
