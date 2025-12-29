note
	description: "Vertical box container (column layout)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_COLUMN

inherit
	SV_BOX

create
	make

feature {NONE} -- Initialization

	make
			-- Create vertical box.
		do
			create ev_vertical_box
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_vertical_box: EV_VERTICAL_BOX
			-- Underlying EiffelVision-2 vertical box.

	ev_box: EV_BOX
			-- Implement SV_BOX requirement.
		do
			Result := ev_vertical_box
		end

feature -- Alignment

	align_top: like Current
			-- Align children to the top.
		do
			-- Default behavior, no special action needed
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_middle: like Current
			-- Center children vertically.
			-- Note: Achieved by adding spacers on both sides.
		do
			-- Will be handled by layout constraints in future
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_bottom: like Current
			-- Align children to the bottom.
			-- Note: Achieved by adding spacer at start.
		do
			-- Will be handled by layout constraints in future
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	ev_vertical_box_exists: ev_vertical_box /= Void

end
