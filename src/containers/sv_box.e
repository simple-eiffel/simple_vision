note
	description: "Base class for box containers (row/column)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SV_BOX

inherit
	SV_CONTAINER
		redefine
			extend
		end

feature -- Access

	ev_box: EV_BOX
			-- Underlying EiffelVision-2 box.
		deferred
		ensure
			result_attached: Result /= Void
		end

	ev_container: EV_CONTAINER
			-- Implement SV_CONTAINER requirement.
		do
			Result := ev_box
		end

feature -- Fluent Configuration

	spacing (a_spacing: INTEGER): like Current
			-- Set spacing between children.
		require
			non_negative: a_spacing >= 0
		do
			ev_box.set_padding (a_spacing)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	padding (a_padding: INTEGER): like Current
			-- Set padding around all children.
		require
			non_negative: a_padding >= 0
		do
			ev_box.set_border_width (a_padding)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	border (a_border: INTEGER): like Current
			-- Fluent alias for padding.
		require
			non_negative: a_border >= 0
		do
			Result := padding (a_border)
		ensure
			result_is_current: Result = Current
		end

feature -- Adding Children

	extend (a_widget: SV_WIDGET)
			-- Add a child widget, respecting its expansion hint.
		do
			Precursor (a_widget)
			if not a_widget.is_expandable then
				ev_box.disable_item_expand (a_widget.ev_widget)
			end
		end

feature -- Children (Fluent)

	children (a_widgets: ARRAY [SV_WIDGET]): like Current
			-- Add multiple children at once.
		require
			widgets_attached: a_widgets /= Void
		local
			i: INTEGER
		do
			from i := a_widgets.lower until i > a_widgets.upper loop
				if attached a_widgets [i] as w then
					extend (w)
				end
				i := i + 1
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	children_ev (a_widgets: ARRAY [EV_WIDGET]): like Current
			-- Add multiple raw EV widgets.
		require
			widgets_attached: a_widgets /= Void
		local
			i: INTEGER
		do
			from i := a_widgets.lower until i > a_widgets.upper loop
				if attached a_widgets [i] as w then
					extend_ev (w)
				end
				i := i + 1
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Child Expansion Control

	expand_child (a_widget: SV_WIDGET): like Current
			-- Allow child to expand.
		require
			widget_attached: a_widget /= Void
			is_child: ev_box.has (a_widget.ev_widget)
		do
			ev_box.enable_item_expand (a_widget.ev_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	shrink_child (a_widget: SV_WIDGET): like Current
			-- Prevent child from expanding.
		require
			widget_attached: a_widget /= Void
			is_child: ev_box.has (a_widget.ev_widget)
		do
			ev_box.disable_item_expand (a_widget.ev_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_homogeneous (a_homogeneous: BOOLEAN): like Current
			-- Set whether all children have equal size.
		do
			if a_homogeneous then
				ev_box.enable_homogeneous
			else
				ev_box.disable_homogeneous
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	homogeneous: like Current
			-- Make all children equal size.
		do
			Result := set_homogeneous (True)
		ensure
			result_is_current: Result = Current
		end

end
