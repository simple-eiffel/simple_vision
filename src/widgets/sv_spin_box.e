note
	description: "Spin box widget for numeric input - wraps EV_SPIN_BUTTON"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SPIN_BOX

inherit
	SV_WIDGET

create
	make,
	make_with_range,
	make_with_value

feature {NONE} -- Initialization

	make
			-- Create spin box with default range 0-100.
		do
			create ev_spin_button
			ev_spin_button.value_range.adapt (0 |..| 100)
			ev_spin_button.set_value (0)
		end

	make_with_range (a_min, a_max: INTEGER)
			-- Create spin box with specified range.
		require
			valid_range: a_min < a_max
		do
			create ev_spin_button
			ev_spin_button.value_range.adapt (a_min |..| a_max)
			ev_spin_button.set_value (a_min)
		ensure
			min_set: minimum = a_min
			max_set: maximum = a_max
		end

	make_with_value (a_value: INTEGER)
			-- Create spin box with initial value (range auto-expands).
		do
			create ev_spin_button
			if a_value < 0 then
				ev_spin_button.value_range.adapt (a_value |..| 100)
			else
				ev_spin_button.value_range.adapt (0 |..| (a_value.max (100)))
			end
			ev_spin_button.set_value (a_value)
		ensure
			value_set: value = a_value
		end

feature -- Access

	ev_spin_button: EV_SPIN_BUTTON
			-- Underlying EiffelVision-2 spin button.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_spin_button
		end

	value: INTEGER
			-- Current spin box value.
		do
			Result := ev_spin_button.value
		end

	minimum: INTEGER
			-- Minimum value.
		do
			Result := ev_spin_button.value_range.lower
		end

	maximum: INTEGER
			-- Maximum value.
		do
			Result := ev_spin_button.value_range.upper
		end

	step: INTEGER
			-- Step size for spin buttons.
		do
			Result := ev_spin_button.step
		end

feature -- Value Operations

	set_value (a_value: INTEGER)
			-- Set spin box value (procedure).
		require
			valid_value: a_value >= minimum and a_value <= maximum
		do
			ev_spin_button.set_value (a_value)
			notify_change
		ensure
			value_set: value = a_value
		end

	at (a_value: INTEGER): like Current
			-- Set spin box value (fluent).
		require
			valid_value: a_value >= minimum and a_value <= maximum
		do
			set_value (a_value)
			Result := Current
		ensure
			value_set: value = a_value
			result_is_current: Result = Current
		end

	increment
			-- Increase value by step.
		do
			if value + step <= maximum then
				set_value (value + step)
			end
		end

	decrement
			-- Decrease value by step.
		do
			if value - step >= minimum then
				set_value (value - step)
			end
		end

	reset
			-- Reset to minimum.
		do
			set_value (minimum)
		ensure
			at_minimum: value = minimum
		end

feature -- Range Configuration

	set_range (a_min, a_max: INTEGER): like Current
			-- Set value range.
		require
			valid_range: a_min < a_max
		do
			ev_spin_button.value_range.adapt (a_min |..| a_max)
			if value < a_min then
				ev_spin_button.set_value (a_min)
			elseif value > a_max then
				ev_spin_button.set_value (a_max)
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
			ev_spin_button.set_step (a_step)
			Result := Current
		ensure
			step_set: step = a_step
			result_is_current: Result = Current
		end

	stepping (a_step: INTEGER): like Current
			-- Fluent alias for set_step.
		require
			positive: a_step > 0
		do
			Result := set_step (a_step)
		ensure
			result_is_current: Result = Current
		end

feature -- Wrapping

	enable_wrap: like Current
			-- Enable wrap-around (max+1 -> min, min-1 -> max).
		do
			is_wrapping := True
			Result := Current
		ensure
			wrapping: is_wrapping
			result_is_current: Result = Current
		end

	disable_wrap: like Current
			-- Disable wrap-around.
		do
			is_wrapping := False
			Result := Current
		ensure
			not_wrapping: not is_wrapping
			result_is_current: Result = Current
		end

	is_wrapping: BOOLEAN
			-- Does value wrap around at boundaries?

feature -- Read-Only

	set_read_only: like Current
			-- Make spin box read-only.
		do
			ev_spin_button.disable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_editable: like Current
			-- Make spin box editable.
		do
			ev_spin_button.enable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	read_only: like Current
			-- Fluent alias for set_read_only.
		do
			Result := set_read_only
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_change (a_action: PROCEDURE)
			-- Set action for value changes.
		require
			action_attached: a_action /= Void
		do
			ev_spin_button.change_actions.extend (agent (v: INTEGER; act: PROCEDURE)
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
			ev_spin_button.change_actions.extend (agent (v: INTEGER; act: PROCEDURE [INTEGER])
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
	ev_spin_button_exists: ev_spin_button /= Void
	valid_value: value >= minimum and value <= maximum

end
