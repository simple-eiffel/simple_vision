note
	description: "Split pane widget - wraps EV_HORIZONTAL_SPLIT_AREA / EV_VERTICAL_SPLIT_AREA"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_SPLITTER

inherit
	SV_WIDGET

create
	make_horizontal,
	make_vertical

feature {NONE} -- Initialization

	make_horizontal
			-- Create horizontal splitter (left/right panes).
		do
			create ev_horizontal_split.default_create
			is_horizontal := True
			apply_theme
			subscribe_to_theme
		end

	make_vertical
			-- Create vertical splitter (top/bottom panes).
		do
			create ev_vertical_split.default_create
			is_horizontal := False
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_horizontal_split: detachable EV_HORIZONTAL_SPLIT_AREA
			-- Horizontal split (if horizontal).

	ev_vertical_split: detachable EV_VERTICAL_SPLIT_AREA
			-- Vertical split (if vertical).

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			if is_horizontal then
				check attached ev_horizontal_split as h then
					Result := h
				end
			else
				check attached ev_vertical_split as v then
					Result := v
				end
			end
		end

	is_horizontal: BOOLEAN
			-- Is this a horizontal splitter?

	is_vertical: BOOLEAN
			-- Is this a vertical splitter?
		do
			Result := not is_horizontal
		end

feature -- Pane Management

	set_first (a_widget: SV_WIDGET)
			-- Set first pane (left or top).
		require
			widget_attached: a_widget /= Void
		do
			if is_horizontal then
				check attached ev_horizontal_split as h then
					h.set_first (a_widget.ev_widget)
				end
			else
				check attached ev_vertical_split as v then
					v.set_first (a_widget.ev_widget)
				end
			end
		end

	set_second (a_widget: SV_WIDGET)
			-- Set second pane (right or bottom).
		require
			widget_attached: a_widget /= Void
		do
			if is_horizontal then
				check attached ev_horizontal_split as h then
					h.set_second (a_widget.ev_widget)
				end
			else
				check attached ev_vertical_split as v then
					v.set_second (a_widget.ev_widget)
				end
			end
		end

	first (a_widget: SV_WIDGET): like Current
			-- Set first pane (fluent).
		require
			widget_attached: a_widget /= Void
		do
			set_first (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	second (a_widget: SV_WIDGET): like Current
			-- Set second pane (fluent).
		require
			widget_attached: a_widget /= Void
		do
			set_second (a_widget)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	left (a_widget: SV_WIDGET): like Current
			-- Set left pane (alias for first, horizontal only).
		require
			widget_attached: a_widget /= Void
			is_horizontal: is_horizontal
		do
			Result := first (a_widget)
		ensure
			result_is_current: Result = Current
		end

	right (a_widget: SV_WIDGET): like Current
			-- Set right pane (alias for second, horizontal only).
		require
			widget_attached: a_widget /= Void
			is_horizontal: is_horizontal
		do
			Result := second (a_widget)
		ensure
			result_is_current: Result = Current
		end

	top (a_widget: SV_WIDGET): like Current
			-- Set top pane (alias for first, vertical only).
		require
			widget_attached: a_widget /= Void
			is_vertical: is_vertical
		do
			Result := first (a_widget)
		ensure
			result_is_current: Result = Current
		end

	bottom (a_widget: SV_WIDGET): like Current
			-- Set bottom pane (alias for second, vertical only).
		require
			widget_attached: a_widget /= Void
			is_vertical: is_vertical
		do
			Result := second (a_widget)
		ensure
			result_is_current: Result = Current
		end

feature -- Split Position

	set_split_position (a_position: INTEGER)
			-- Set splitter position in pixels.
		require
			positive: a_position >= 0
		do
			if is_horizontal then
				check attached ev_horizontal_split as h then
					h.set_split_position (a_position)
				end
			else
				check attached ev_vertical_split as v then
					v.set_split_position (a_position)
				end
			end
		end

	split_position: INTEGER
			-- Current split position.
		do
			if is_horizontal then
				check attached ev_horizontal_split as h then
					Result := h.split_position
				end
			else
				check attached ev_vertical_split as v then
					Result := v.split_position
				end
			end
		end

	at_position (a_position: INTEGER): like Current
			-- Set split position (fluent).
		require
			positive: a_position >= 0
		do
			set_split_position (a_position)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_proportion (a_proportion: REAL_64)
			-- Set split as proportion (0.0 to 1.0).
		require
			valid_proportion: a_proportion >= 0.0 and a_proportion <= 1.0
		do
			proportion := a_proportion
			-- Applied when widget is displayed
		end

	proportion: REAL_64
			-- Proportion for first pane (0.0 to 1.0).

	at_proportion (a_proportion: REAL_64): like Current
			-- Set proportion (fluent).
		require
			valid_proportion: a_proportion >= 0.0 and a_proportion <= 1.0
		do
			set_proportion (a_proportion)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	one_split: (ev_horizontal_split /= Void) xor (ev_vertical_split /= Void)

end
