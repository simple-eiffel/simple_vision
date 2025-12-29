note
	description: "Horizontal box container (row layout)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_ROW

inherit
	SV_BOX

create
	make

feature {NONE} -- Initialization

	make
			-- Create horizontal box.
		do
			create ev_horizontal_box
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_horizontal_box: EV_HORIZONTAL_BOX
			-- Underlying EiffelVision-2 horizontal box.

	ev_box: EV_BOX
			-- Implement SV_BOX requirement.
		do
			Result := ev_horizontal_box
		end

feature -- Alignment

	align_left: like Current
			-- Align children to the left.
		do
			-- Default behavior, no special action needed
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_center: like Current
			-- Center children horizontally.
			-- Note: Achieved by adding spacers on both sides.
		do
			-- Will be handled by layout constraints in future
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	align_right: like Current
			-- Align children to the right.
			-- Note: Achieved by adding spacer at start.
		do
			-- Will be handled by layout constraints in future
			Result := Current
		ensure
			result_is_current: Result = Current
		end

invariant
	ev_horizontal_box_exists: ev_horizontal_box /= Void

end
