note
	description: "Abstract validation rule for form fields"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SV_VALIDATION_RULE [G]

feature -- Validation

	validate (a_value: G): BOOLEAN
			-- Does `a_value` pass this validation rule?
		deferred
		end

	message: STRING
			-- Error message when validation fails.
		deferred
		end

end
