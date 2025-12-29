note
	description: "Base class for container widgets"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SV_CONTAINER

inherit
	SV_WIDGET

feature -- Access

	ev_container: EV_CONTAINER
			-- Underlying EiffelVision-2 container.
		deferred
		ensure
			result_attached: Result /= Void
		end

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_container
		end

feature -- Children

	children_count: INTEGER
			-- Number of child widgets.
		do
			Result := ev_container.count
		end

	is_empty: BOOLEAN
			-- Does this container have no children?
		do
			Result := ev_container.is_empty
		end

feature -- Adding Children

	extend (a_widget: SV_WIDGET)
			-- Add a child widget (procedure for statement use).
		require
			widget_attached: a_widget /= Void
		do
			ev_container.extend (a_widget.ev_widget)
		ensure
			child_added: children_count = old children_count + 1
		end

	extend_ev (a_widget: EV_WIDGET)
			-- Add a raw EV widget (procedure for statement use).
		require
			widget_attached: a_widget /= Void
		do
			ev_container.extend (a_widget)
		end

	add (a_widget: SV_WIDGET): like Current
			-- Add a child widget (fluent).
		require
			widget_attached: a_widget /= Void
		do
			extend (a_widget)
			Result := Current
		ensure
			child_added: children_count = old children_count + 1
			result_is_current: Result = Current
		end

	add_ev (a_widget: EV_WIDGET): like Current
			-- Add a raw EV widget (fluent, for interop).
		require
			widget_attached: a_widget /= Void
		do
			extend_ev (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Removing Children

	remove_all: like Current
			-- Remove all children.
		do
			ev_container.wipe_out
			Result := Current
		ensure
			empty: is_empty
			result_is_current: Result = Current
		end

end
