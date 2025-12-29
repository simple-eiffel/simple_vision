note
	description: "Validation rule requiring maximum string length"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MAX_LENGTH_RULE

inherit
	SV_VALIDATION_RULE [READABLE_STRING_GENERAL]

create
	make

feature {NONE} -- Initialization

	make (a_max: INTEGER)
			-- Create rule requiring at most `a_max` characters.
		require
			positive: a_max > 0
		do
			max_length := a_max
		ensure
			max_set: max_length = a_max
		end

feature -- Access

	max_length: INTEGER
			-- Maximum allowed length.

feature -- Validation

	validate (a_value: READABLE_STRING_GENERAL): BOOLEAN
			-- Does value have at most max_length characters?
		do
			Result := a_value.count <= max_length
		end

	message: STRING
			-- Error message.
		do
			Result := "Must be at most " + max_length.out + " characters"
		end

end
