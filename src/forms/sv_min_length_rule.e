note
	description: "Validation rule requiring minimum string length"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_MIN_LENGTH_RULE

inherit
	SV_VALIDATION_RULE [READABLE_STRING_GENERAL]

create
	make

feature {NONE} -- Initialization

	make (a_min: INTEGER)
			-- Create rule requiring at least `a_min` characters.
		require
			positive: a_min >= 0
		do
			min_length := a_min
		ensure
			min_set: min_length = a_min
		end

feature -- Access

	min_length: INTEGER
			-- Minimum required length.

feature -- Validation

	validate (a_value: READABLE_STRING_GENERAL): BOOLEAN
			-- Does value have at least min_length characters?
		do
			Result := a_value.count >= min_length
		end

	message: STRING
			-- Error message.
		do
			Result := "Must be at least " + min_length.out + " characters"
		end

end
