note
	description: "Slider/range widget - wraps EV_HORIZONTAL_RANGE"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SLIDER

inherit
	SV_WIDGET

create
	make,
	make_with_range

feature {NONE} -- Initialization

	make
			-- Create slider with default range 0-100.
		do
			create ev_range
			ev_range.value_range.adapt (0 |..| 100)
			ev_range.set_value (0)
			step := 1
		end

	make_with_range (a_min, a_max: INTEGER)
			-- Create slider with specified range.
		require
			valid_range: a_min < a_max
		do
			create ev_range
			ev_range.value_range.adapt (a_min |..| a_max)
			ev_range.set_value (a_min)
			step := 1
		ensure
			min_set: minimum = a_min
			max_set: maximum = a_max
		end

feature -- Access

	ev_range: EV_HORIZONTAL_RANGE
			-- Underlying EiffelVision-2 range widget.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_range
		end

	value: INTEGER
			-- Current slider value.
		do
			Result := ev_range.value
		end

	minimum: INTEGER
			-- Minimum value.
		do
			Result := ev_range.value_range.lower
		end

	maximum: INTEGER
			-- Maximum value.
		do
			Result := ev_range.value_range.upper
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

feature -- Value Operations

	set_value (a_value: INTEGER)
			-- Set slider value (procedure).
		require
			valid_value: a_value >= minimum and a_value <= maximum
		do
			ev_range.set_value (a_value)
			notify_change
		ensure
			value_set: value = a_value
		end

	at (a_value: INTEGER): like Current
			-- Set slider value (fluent).
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

	increment
			-- Increase value by step.
		do
			if value + step <= maximum then
				set_value (value + step)
			else
				set_value (maximum)
			end
		end

	decrement
			-- Decrease value by step.
		do
			if value - step >= minimum then
				set_value (value - step)
			else
				set_value (minimum)
			end
		end

feature -- Range Configuration

	set_range (a_min, a_max: INTEGER): like Current
			-- Set value range.
		require
			valid_range: a_min < a_max
		do
			ev_range.value_range.adapt (a_min |..| a_max)
			if value < a_min then
				ev_range.set_value (a_min)
			elseif value > a_max then
				ev_range.set_value (a_max)
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

	set_step (a_step: INTEGER): like Current
			-- Set increment/decrement step size.
		require
			positive: a_step > 0
		do
			step := a_step
			ev_range.set_step (a_step)
			Result := Current
		ensure
			step_set: step = a_step
			result_is_current: Result = Current
		end

	step: INTEGER
			-- Step size for increment/decrement.

feature -- Orientation

	vertical: like Current
			-- Switch to vertical orientation.
			-- Note: Creates new vertical range widget.
		local
			l_vrange: EV_VERTICAL_RANGE
		do
			create l_vrange
			l_vrange.value_range.adapt (minimum |..| maximum)
			l_vrange.set_value (value)
			-- Would need to replace ev_range with vertical version
			-- This is a design placeholder
			is_vertical := True
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	is_vertical: BOOLEAN
			-- Is slider vertical?

feature -- Events

	on_change (a_action: PROCEDURE)
			-- Set action for value changes.
		require
			action_attached: a_action /= Void
		do
			ev_range.change_actions.extend (agent (v: INTEGER; act: PROCEDURE)
				do
					act.call (Void)
				end (?, a_action))
		end

	changed (a_action: PROCEDURE): like Current
			-- Fluent version of on_change.
		require
			action_attached: a_action /= Void
		do
			on_change (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	on_value (a_action: PROCEDURE [INTEGER]): like Current
			-- Set action that receives the new value.
		require
			action_attached: a_action /= Void
		do
			ev_range.change_actions.extend (agent (v: INTEGER; act: PROCEDURE [INTEGER])
				do
					act.call ([v])
				end (?, a_action))
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature {NONE} -- Implementation

	notify_change
			-- Notify harness of value change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("value", "", value.out))
			end
		end

invariant
	ev_range_exists: ev_range /= Void
	valid_value: value >= minimum and value <= maximum

end
