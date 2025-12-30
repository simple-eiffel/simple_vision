note
	description: "Progress bar widget - wraps EV_HORIZONTAL_PROGRESS_BAR"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_PROGRESS_BAR

inherit
	SV_WIDGET

create
	make,
	make_with_range

feature {NONE} -- Initialization

	make
			-- Create progress bar with default range 0-100.
		do
			create ev_progress
			ev_progress.value_range.adapt (0 |..| 100)
			ev_progress.set_value (0)
		end

	make_with_range (a_min, a_max: INTEGER)
			-- Create progress bar with specified range.
		require
			valid_range: a_min < a_max
		do
			create ev_progress
			ev_progress.value_range.adapt (a_min |..| a_max)
			ev_progress.set_value (a_min)
		ensure
			min_set: minimum = a_min
			max_set: maximum = a_max
		end

feature -- Access

	ev_progress: EV_HORIZONTAL_PROGRESS_BAR
			-- Underlying EiffelVision-2 progress bar widget.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_progress
		end

	value: INTEGER
			-- Current progress value.
		do
			Result := ev_progress.value
		end

	minimum: INTEGER
			-- Minimum value.
		do
			Result := ev_progress.value_range.lower
		end

	maximum: INTEGER
			-- Maximum value.
		do
			Result := ev_progress.value_range.upper
		end

	percentage: REAL_64
			-- Current value as percentage (0.0 to 1.0).
		do
			if maximum > minimum then
				Result := (value - minimum) / (maximum - minimum)
			end
		ensure
			valid_range: Result >= 0.0 and Result <= 1.0
		end

	percent_int: INTEGER
			-- Current value as integer percentage (0 to 100).
		do
			Result := (percentage * 100).truncated_to_integer
		ensure
			valid_range: Result >= 0 and Result <= 100
		end

feature -- Value Operations

	set_value (a_value: INTEGER)
			-- Set progress value (procedure).
		require
			valid_value: a_value >= minimum and a_value <= maximum
		do
			ev_progress.set_value (a_value)
		ensure
			value_set: value = a_value
		end

	at (a_value: INTEGER): like Current
			-- Set progress value (fluent).
		require
			valid_value: a_value >= minimum and a_value <= maximum
		do
			set_value (a_value)
			Result := Current
		ensure
			value_set: value = a_value
			result_is_current: Result = Current
		end

	set_percentage (a_percent: REAL_64)
			-- Set value by percentage (0.0 to 1.0).
		require
			valid_percent: a_percent >= 0.0 and a_percent <= 1.0
		local
			l_value: INTEGER
		do
			l_value := minimum + ((maximum - minimum) * a_percent).truncated_to_integer
			set_value (l_value)
		end

	set_percent (a_percent: INTEGER)
			-- Set value by integer percentage (0 to 100).
		require
			valid_percent: a_percent >= 0 and a_percent <= 100
		do
			set_percentage (a_percent / 100.0)
		end

	advance (a_amount: INTEGER)
			-- Advance progress by amount.
		do
			if value + a_amount <= maximum then
				set_value (value + a_amount)
			else
				set_value (maximum)
			end
		end

	reset
			-- Reset to minimum.
		do
			set_value (minimum)
		ensure
			at_minimum: value = minimum
		end

	complete
			-- Set to maximum.
		do
			set_value (maximum)
		ensure
			at_maximum: value = maximum
		end

feature -- Range Configuration

	set_range (a_min, a_max: INTEGER): like Current
			-- Set value range.
		require
			valid_range: a_min < a_max
		do
			ev_progress.value_range.adapt (a_min |..| a_max)
			if value < a_min then
				ev_progress.set_value (a_min)
			elseif value > a_max then
				ev_progress.set_value (a_max)
			end
			Result := Current
		ensure
			min_set: minimum = a_min
			max_set: maximum = a_max
			result_is_current: Result = Current
		end

	range (a_min, a_max: INTEGER): like Current
			-- Fluent alias for set_range.
		require
			valid_range: a_min < a_max
		do
			Result := set_range (a_min, a_max)
		ensure
			result_is_current: Result = Current
		end

feature -- Status

	is_complete: BOOLEAN
			-- Is progress at maximum?
		do
			Result := value >= maximum
		end

	is_started: BOOLEAN
			-- Has progress started (above minimum)?
		do
			Result := value > minimum
		end

invariant
	ev_progress_exists: ev_progress /= Void
	valid_value: value >= minimum and value <= maximum

end
