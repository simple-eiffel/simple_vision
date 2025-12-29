note
	description: "Validation rule for email addresses"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_EMAIL_RULE

inherit
	SV_PATTERN_RULE
		rename
			make as make_pattern,
			make_with_message as make_pattern_with_message
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create email validation rule.
		do
			make_pattern_with_message (email_pattern, "Please enter a valid email address")
		end

feature {NONE} -- Constants

	email_pattern: STRING = "^[a-zA-Z0-9._%%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
			-- Standard email regex pattern.

end
