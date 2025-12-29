note
	description: "Scrollable container - wraps EV_SCROLLABLE_AREA"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SCROLL

inherit
	SV_WIDGET

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty scrollable area.
		do
			create ev_scrollable_area
			ev_widget := ev_scrollable_area
		end

feature -- Access

	ev_scrollable_area: EV_SCROLLABLE_AREA
			-- Underlying EiffelVision-2 scrollable area.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	has_content: BOOLEAN
			-- Does scroll area have content?
		do
			Result := not ev_scrollable_area.is_empty
		end

	horizontal_offset: INTEGER
			-- Current horizontal scroll position.
		do
			Result := ev_scrollable_area.x_offset
		end

	vertical_offset: INTEGER
			-- Current vertical scroll position.
		do
			Result := ev_scrollable_area.y_offset
		end

feature -- Configuration

	set_content (a_widget: SV_WIDGET)
			-- Set scrollable content.
		require
			widget_attached: a_widget /= Void
		do
			ev_scrollable_area.wipe_out
			ev_scrollable_area.extend (a_widget.ev_widget)
		end

	scroll_to (a_x, a_y: INTEGER)
			-- Scroll to position.
		require
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			ev_scrollable_area.set_x_offset (a_x)
			ev_scrollable_area.set_y_offset (a_y)
		end

	scroll_to_top
			-- Scroll to top.
		do
			ev_scrollable_area.set_y_offset (0)
		end

	scroll_to_bottom
			-- Scroll to bottom.
		do
			-- Set to maximum offset (content height - visible height)
			if attached ev_scrollable_area.item as l_item then
				ev_scrollable_area.set_y_offset (l_item.height - ev_scrollable_area.height)
			end
		end

	scroll_to_left
			-- Scroll to left.
		do
			ev_scrollable_area.set_x_offset (0)
		end

feature -- Fluent Configuration

	content (a_widget: SV_WIDGET): like Current
			-- Set content (fluent).
		require
			widget_attached: a_widget /= Void
		do
			set_content (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	at_offset (a_x, a_y: INTEGER): like Current
			-- Set initial scroll position (fluent).
		require
			valid_x: a_x >= 0
			valid_y: a_y >= 0
		do
			scroll_to (a_x, a_y)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Removal

	clear
			-- Remove content.
		do
			ev_scrollable_area.wipe_out
		ensure
			no_content: not has_content
		end

invariant
	ev_scrollable_area_exists: ev_scrollable_area /= Void

end
