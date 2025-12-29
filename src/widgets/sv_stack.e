note
	description: "Stack layout with absolute positioning - wraps EV_FIXED"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_STACK

inherit
	SV_WIDGET

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty stack.
		do
			create ev_fixed
			ev_widget := ev_fixed
		end

feature -- Access

	ev_fixed: EV_FIXED
			-- Underlying EiffelVision-2 fixed container.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	count: INTEGER
			-- Number of children.
		do
			Result := ev_fixed.count
		end

	is_empty: BOOLEAN
			-- Is stack empty?
		do
			Result := ev_fixed.is_empty
		end

feature -- Adding Widgets

	add (a_widget: SV_WIDGET; a_x, a_y: INTEGER)
			-- Add widget at absolute position.
		require
			widget_attached: a_widget /= Void
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			ev_fixed.extend (a_widget.ev_widget)
			ev_fixed.set_item_position (a_widget.ev_widget, a_x, a_y)
		end

	add_sized (a_widget: SV_WIDGET; a_x, a_y, a_width, a_height: INTEGER)
			-- Add widget at position with size.
		require
			widget_attached: a_widget /= Void
			valid_x: a_x >= 0
			valid_y: a_y >= 0
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			ev_fixed.extend (a_widget.ev_widget)
			ev_fixed.set_item_position (a_widget.ev_widget, a_x, a_y)
			ev_fixed.set_item_size (a_widget.ev_widget, a_width, a_height)
		end

	move (a_widget: SV_WIDGET; a_x, a_y: INTEGER)
			-- Move existing widget to new position.
		require
			widget_attached: a_widget /= Void
			widget_in_stack: ev_fixed.has (a_widget.ev_widget)
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			ev_fixed.set_item_position (a_widget.ev_widget, a_x, a_y)
		end

	resize (a_widget: SV_WIDGET; a_width, a_height: INTEGER)
			-- Resize existing widget.
		require
			widget_attached: a_widget /= Void
			widget_in_stack: ev_fixed.has (a_widget.ev_widget)
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			ev_fixed.set_item_size (a_widget.ev_widget, a_width, a_height)
		end

feature -- Fluent Configuration

	positioned (a_widget: SV_WIDGET; a_x, a_y: INTEGER): like Current
			-- Add widget at position (fluent).
		require
			widget_attached: a_widget /= Void
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			add (a_widget, a_x, a_y)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	layer (a_widget: SV_WIDGET): like Current
			-- Add widget at origin (fluent) - layers stack.
		require
			widget_attached: a_widget /= Void
		do
			add (a_widget, 0, 0)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Removal

	remove (a_widget: SV_WIDGET)
			-- Remove widget from stack.
		require
			widget_attached: a_widget /= Void
		do
			ev_fixed.prune (a_widget.ev_widget)
		end

	clear
			-- Remove all widgets.
		do
			ev_fixed.wipe_out
		ensure
			is_empty: is_empty
		end

invariant
	ev_fixed_exists: ev_fixed /= Void

end
