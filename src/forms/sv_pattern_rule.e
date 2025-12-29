note
	description: "Validation rule requiring regex pattern match"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_PATTERN_RULE

inherit
	SV_VALIDATION_RULE [READABLE_STRING_GENERAL]

create
	make,
	make_with_message

feature {NONE} -- Initialization

	make (a_pattern: STRING)
			-- Create rule requiring match to `a_pattern`.
		require
			pattern_not_empty: not a_pattern.is_empty
		do
			pattern := a_pattern
			custom_message := Void
			create regex.make
			regex.compile (pattern)
		ensure
			pattern_set: pattern.same_string (a_pattern)
		end

	make_with_message (a_pattern: STRING; a_message: STRING)
			-- Create rule with custom error message.
		require
			pattern_not_empty: not a_pattern.is_empty
			message_not_empty: not a_message.is_empty
		do
			pattern := a_pattern
			custom_message := a_message
			create regex.make
			regex.compile (pattern)
		ensure
			pattern_set: pattern.same_string (a_pattern)
			message_set: attached custom_message as m and then m.same_string (a_message)
		end

feature -- Access

	pattern: STRING
			-- Regex pattern to match.

	custom_message: detachable STRING
			-- Custom error message (if provided).

feature -- Validation

	validate (a_value: READABLE_STRING_GENERAL): BOOLEAN
			-- Does value match the pattern?
		local
			l_match: SIMPLE_REGEX_MATCH
		do
			if regex.is_compiled then
				l_match := regex.match (a_value.to_string_8)
				Result := l_match.is_matched
			else
				Result := False -- Pattern didn't compile
			end
		end

	message: STRING
			-- Error message.
		do
			if attached custom_message as cm then
				Result := cm
			else
				Result := "Invalid format"
			end
		end

feature {NONE} -- Implementation

	regex: SIMPLE_REGEX
			-- Compiled regex.

invariant
	regex_exists: regex /= Void

end
