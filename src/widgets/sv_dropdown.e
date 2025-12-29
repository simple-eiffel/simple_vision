note
	description: "Dropdown/combo box widget - wraps EV_COMBO_BOX"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_DROPDOWN

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make,
	make_with_options

feature {NONE} -- Initialization

	make
			-- Create empty dropdown.
		do
			create ev_combo_box
			create option_values.make (10)
			apply_theme
			subscribe_to_theme
		end

	make_with_options (a_options: ARRAY [STRING])
			-- Create dropdown with options.
		require
			options_attached: a_options /= Void
		do
			make
			across a_options as opt loop
				add_option (opt.item)
			end
		end

feature -- Access

	ev_combo_box: EV_COMBO_BOX
			-- Underlying EiffelVision-2 combo box.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_combo_box
		end

	option_values: ARRAYED_LIST [STRING]
			-- Values associated with each option.

	selected_index: INTEGER
			-- Index of selected option (0 if none).
		do
			if attached ev_combo_box.selected_item as item then
				Result := ev_combo_box.index_of (item, 1)
			end
		end

	selected_text: STRING_32
			-- Text of selected option.
		do
			if attached ev_combo_box.selected_item as item then
				Result := item.text
			else
				Result := ""
			end
		end

	selected_value: STRING
			-- Value of selected option.
		do
			if selected_index > 0 and selected_index <= option_values.count then
				Result := option_values [selected_index]
			else
				Result := ""
			end
		end

	text: STRING_32
			-- Current text (may be edited if editable).
		do
			Result := ev_combo_box.text
		end

feature -- Options

	add_option (a_text: STRING)
			-- Add an option.
		require
			text_not_empty: not a_text.is_empty
		local
			l_item: EV_LIST_ITEM
		do
			create l_item.make_with_text (a_text)
			ev_combo_box.extend (l_item)
			option_values.extend (a_text)
		ensure
			added: ev_combo_box.count = old ev_combo_box.count + 1
		end

	add_option_with_value (a_text, a_value: STRING)
			-- Add option with separate display text and value.
		require
			text_not_empty: not a_text.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_item: EV_LIST_ITEM
		do
			create l_item.make_with_text (a_text)
			ev_combo_box.extend (l_item)
			option_values.extend (a_value)
		end

	options (a_options: ARRAY [STRING]): like Current
			-- Add multiple options (fluent).
		require
			options_attached: a_options /= Void
		do
			across a_options as opt loop
				add_option (opt.item)
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear_options
			-- Remove all options.
		do
			ev_combo_box.wipe_out
			option_values.wipe_out
		ensure
			empty: ev_combo_box.is_empty
		end

feature -- Selection

	select_index (a_index: INTEGER)
			-- Select option by index.
		require
			valid_index: a_index >= 1 and a_index <= ev_combo_box.count
		do
			ev_combo_box.i_th (a_index).enable_select
			notify_selection_change
		ensure
			selected: selected_index = a_index
		end

	select_value (a_value: STRING)
			-- Select option by value.
		require
			value_not_empty: not a_value.is_empty
		local
			i: INTEGER
		do
			from i := 1 until i > option_values.count loop
				if option_values [i].same_string (a_value) then
					select_index (i)
				end
				i := i + 1
			end
		end

	select_first
			-- Select first option.
		require
			has_options: ev_combo_box.count > 0
		do
			select_index (1)
		end

	selected (a_index: INTEGER): like Current
			-- Select option by index (fluent).
		require
			valid_index: a_index >= 1 and a_index <= ev_combo_box.count
		do
			select_index (a_index)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Editing

	set_editable: like Current
			-- Allow typing in dropdown.
		do
			ev_combo_box.enable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_read_only: like Current
			-- Prevent typing (selection only).
		do
			ev_combo_box.disable_edit
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	editable: like Current
			-- Fluent alias for set_editable.
		do
			Result := set_editable
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

feature -- Placeholder

	placeholder (a_text: READABLE_STRING_GENERAL): like Current
			-- Set placeholder text (shows when nothing selected).
		require
			text_not_void: a_text /= Void
		do
			ev_combo_box.set_text (a_text.to_string_32)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_select (a_action: PROCEDURE)
			-- Set action for selection change.
		require
			action_attached: a_action /= Void
		do
			ev_combo_box.select_actions.extend (a_action)
		end

	on_change (a_action: PROCEDURE)
			-- Set action for text change (if editable).
		require
			action_attached: a_action /= Void
		do
			ev_combo_box.change_actions.extend (a_action)
		end

	selected_action (a_action: PROCEDURE): like Current
			-- Fluent version of on_select.
		require
			action_attached: a_action /= Void
		do
			on_select (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled font to dropdown.
		do
			ev_combo_box.set_background_color (tokens.surface.to_ev_color)
			ev_combo_box.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_combo_box.set_font (theme.scaled_font)
		end

feature {NONE} -- Implementation

	notify_selection_change
			-- Notify harness of selection change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("selection", "", selected_value))
			end
		end

invariant
	ev_combo_box_exists: ev_combo_box /= Void
	option_values_exists: option_values /= Void

end
