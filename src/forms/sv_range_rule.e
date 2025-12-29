note
	description: "Validation rule for numeric range"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_RANGE_RULE

inherit
	SV_VALIDATION_RULE [REAL_64]

create
	make,
	make_min,
	make_max

feature {NONE} -- Initialization

	make (a_min, a_max: REAL_64)
			-- Create rule requiring value between `a_min` and `a_max` inclusive.
		require
			valid_range: a_min <= a_max
		do
			min_value := a_min
			max_value := a_max
			has_min := True
			has_max := True
		ensure
			min_set: min_value = a_min
			max_set: max_value = a_max
		end

	make_min (a_min: REAL_64)
			-- Create rule requiring value >= `a_min`.
		do
			min_value := a_min
			max_value := {REAL_64}.max_value
			has_min := True
			has_max := False
		ensure
			min_set: min_value = a_min
		end

	make_max (a_max: REAL_64)
			-- Create rule requiring value <= `a_max`.
		do
			min_value := {REAL_64}.min_value
			max_value := a_max
			has_min := False
			has_max := True
		ensure
			max_set: max_value = a_max
		end

feature -- Access

	min_value: REAL_64
			-- Minimum allowed value.

	max_value: REAL_64
			-- Maximum allowed value.

	has_min: BOOLEAN
			-- Is there a minimum constraint?

	has_max: BOOLEAN
			-- Is there a maximum constraint?

feature -- Validation

	validate (a_value: REAL_64): BOOLEAN
			-- Is value within range?
		do
			Result := a_value >= min_value and a_value <= max_value
		end

	message: STRING
			-- Error message.
		do
			if has_min and has_max then
				Result := "Must be between " + min_value.out + " and " + max_value.out
			elseif has_min then
				Result := "Must be at least " + min_value.out
			else
				Result := "Must be at most " + max_value.out
			end
		end

end
