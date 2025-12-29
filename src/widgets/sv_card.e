note
	description: "Card/Panel container with optional border and title - wraps EV_FRAME"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_CARD

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_title

feature {NONE} -- Initialization

	make
			-- Create empty card.
		do
			create ev_frame
			ev_widget := ev_frame
			apply_theme
			subscribe_to_theme
		end

	make_with_title (a_title: READABLE_STRING_GENERAL)
			-- Create card with title.
		require
			title_not_void: a_title /= Void
		do
			make
			ev_frame.set_text (a_title)
		end

feature -- Access

	ev_frame: EV_FRAME
			-- Underlying EiffelVision-2 frame.

	ev_widget: EV_WIDGET
			-- Widget for container operations.

	title: STRING_32
			-- Card title.
		do
			Result := ev_frame.text
		end

	has_content: BOOLEAN
			-- Does card have content?
		do
			Result := not ev_frame.is_empty
		end

feature -- Configuration

	set_title (a_title: READABLE_STRING_GENERAL)
			-- Set card title.
		require
			title_not_void: a_title /= Void
		do
			ev_frame.set_text (a_title)
		end

	set_content (a_widget: SV_WIDGET)
			-- Set card content.
		require
			widget_attached: a_widget /= Void
		do
			ev_frame.wipe_out
			ev_frame.extend (a_widget.ev_widget)
		end

	set_border_style (a_style: INTEGER)
			-- Set border style.
			-- 0 = none, 1 = lowered, 2 = raised, 3 = etched
		require
			valid_style: a_style >= 0 and a_style <= 3
		do
			inspect a_style
			when 0 then
				-- No direct method for no border
			when 1 then
				ev_frame.set_style ({EV_FRAME_CONSTANTS}.ev_frame_lowered)
			when 2 then
				ev_frame.set_style ({EV_FRAME_CONSTANTS}.ev_frame_raised)
			when 3 then
				ev_frame.set_style ({EV_FRAME_CONSTANTS}.ev_frame_etched_in)
			end
		end

feature -- Fluent Configuration

	titled (a_title: READABLE_STRING_GENERAL): like Current
			-- Set title (fluent).
		require
			title_not_void: a_title /= Void
		do
			set_title (a_title)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

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

	lowered: like Current
			-- Set lowered border style (fluent).
		do
			set_border_style (1)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	raised: like Current
			-- Set raised border style (fluent).
		do
			set_border_style (2)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	etched: like Current
			-- Set etched border style (fluent).
		do
			set_border_style (3)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Removal

	clear
			-- Remove content.
		do
			ev_frame.wipe_out
		ensure
			no_content: not has_content
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to card.
		do
			ev_frame.set_background_color (tokens.surface.to_ev_color)
			ev_frame.set_foreground_color (tokens.text_primary.to_ev_color)
		end

invariant
	ev_frame_exists: ev_frame /= Void

end
