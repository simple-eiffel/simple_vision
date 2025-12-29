note
	description: "Validation rule requiring non-empty value"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_REQUIRED_RULE

inherit
	SV_VALIDATION_RULE [detachable ANY]

feature -- Validation

	validate (a_value: detachable ANY): BOOLEAN
			-- Is value present and non-empty?
		do
			if a_value = Void then
				Result := False
			elseif attached {READABLE_STRING_GENERAL} a_value as s then
				Result := not s.is_empty
			else
				Result := True -- Non-string, non-void is considered present
			end
		end

	message: STRING = "This field is required"

end
