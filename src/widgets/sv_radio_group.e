note
	description: "Radio button group - wraps multiple EV_RADIO_BUTTONs in a box"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_RADIO_GROUP

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
			-- Create empty radio group.
		do
			create ev_vertical_box
			create radio_buttons.make (5)
			create option_values.make (5)
			apply_theme
			subscribe_to_theme
		end

	make_with_options (a_options: ARRAY [STRING])
			-- Create radio group with options.
		require
			options_attached: a_options /= Void
			options_not_empty: not a_options.is_empty
		do
			make
			across a_options as opt loop
				add_option (opt.item)
			end
		ensure
			options_added: radio_buttons.count = a_options.count
		end

feature -- Access

	ev_vertical_box: EV_VERTICAL_BOX
			-- Container for radio buttons.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_vertical_box
		end

	radio_buttons: ARRAYED_LIST [EV_RADIO_BUTTON]
			-- Individual radio buttons.

	option_values: ARRAYED_LIST [STRING]
			-- Values associated with each option.

	selected_index: INTEGER
			-- Index of selected option (0 if none).
		do
			across radio_buttons as rb loop
				if rb.item.is_selected then
					Result := rb.cursor_index
				end
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

feature -- Options

	add_option (a_label: STRING)
			-- Add a radio option.
			-- Note: Radio buttons automatically form a group when added to the same container.
		require
			label_not_empty: not a_label.is_empty
		local
			l_radio: EV_RADIO_BUTTON
		do
			create l_radio.make_with_text (a_label)
			radio_buttons.extend (l_radio)
			option_values.extend (a_label)
			ev_vertical_box.extend (l_radio)
			l_radio.select_actions.extend (agent on_selection_changed)
		ensure
			added: radio_buttons.count = old radio_buttons.count + 1
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

	add_option_with_value (a_label, a_value: STRING)
			-- Add option with separate display label and value.
		require
			label_not_empty: not a_label.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_radio: EV_RADIO_BUTTON
		do
			create l_radio.make_with_text (a_label)
			radio_buttons.extend (l_radio)
			option_values.extend (a_value)
			ev_vertical_box.extend (l_radio)
			l_radio.select_actions.extend (agent on_selection_changed)
		end

feature -- Selection

	select_index (a_index: INTEGER)
			-- Select option by index.
		require
			valid_index: a_index >= 1 and a_index <= radio_buttons.count
		do
			radio_buttons [a_index].enable_select
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

	selected (a_index: INTEGER): like Current
			-- Select option by index (fluent).
		require
			valid_index: a_index >= 1 and a_index <= radio_buttons.count
		do
			select_index (a_index)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Layout

	horizontal: like Current
			-- Arrange options horizontally.
		local
			l_hbox: EV_HORIZONTAL_BOX
		do
			create l_hbox
			across radio_buttons as rb loop
				ev_vertical_box.prune (rb.item)
				l_hbox.extend (rb.item)
			end
			ev_vertical_box.extend (l_hbox)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	spacing (a_spacing: INTEGER): like Current
			-- Set spacing between options.
		require
			non_negative: a_spacing >= 0
		do
			ev_vertical_box.set_padding (a_spacing)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Events

	on_change (a_action: PROCEDURE [STRING])
			-- Set action for selection change.
			-- Action receives the selected value.
		require
			action_attached: a_action /= Void
		do
			change_action := a_action
		end

	changed (a_action: PROCEDURE [STRING]): like Current
			-- Fluent version of on_change.
		require
			action_attached: a_action /= Void
		do
			on_change (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors and scaled fonts to radio group and all buttons.
		do
			ev_vertical_box.set_background_color (tokens.surface.to_ev_color)
			across radio_buttons as rb loop
				rb.item.set_background_color (tokens.surface.to_ev_color)
				rb.item.set_foreground_color (tokens.text_primary.to_ev_color)
				rb.item.set_font (theme.scaled_font)
			end
		end

feature {NONE} -- Implementation

	change_action: detachable PROCEDURE [STRING]
			-- Action to call on selection change.

	on_selection_changed
			-- Handle selection change.
		do
			if attached change_action as act then
				act.call ([selected_value])
			end
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("selection", "", selected_value))
			end
		end

invariant
	ev_vertical_box_exists: ev_vertical_box /= Void
	radio_buttons_exists: radio_buttons /= Void
	option_values_exists: option_values /= Void
	counts_match: radio_buttons.count = option_values.count

end
