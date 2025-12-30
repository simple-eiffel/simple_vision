note
	description: "Base class for all simple_vision widgets"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SV_WIDGET

inherit
	SV_ANY

feature -- Access

	ev_widget: EV_WIDGET
			-- Underlying EiffelVision-2 widget.
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- Theme

	apply_theme
			-- Apply current theme colors and fonts to this widget.
			-- Override in descendants to apply widget-specific styling.
		do
			-- Default: apply background color from theme
			if attached {EV_COLORIZABLE} ev_widget as l_colorizable then
				l_colorizable.set_background_color (tokens.background.to_ev_color)
			end
		end

	subscribe_to_theme
			-- Subscribe to theme and font scale change notifications.
			-- Call this after widget creation.
		do
			theme.on_theme_change.extend (agent on_theme_changed)
			theme.on_font_scale_change.extend (agent on_scale_changed)
		end

feature {NONE} -- Theme Implementation

	on_theme_changed (a_old_tokens, a_new_tokens: SV_TOKENS)
			-- Handle theme change event.
		do
			apply_theme
		end

	on_scale_changed (a_old_scale, a_new_scale: REAL)
			-- Handle font/UI scale change event.
		do
			apply_theme
		end

feature -- Identification

	widget_id: STRING
			-- Stable identifier for testing/automation.
			-- Format: "{type}_{name}" e.g., "button_submit"
		attribute
			Result := ""
		end

	has_id: BOOLEAN
			-- Has this widget been assigned an ID?
		do
			Result := not widget_id.is_empty
		end

	set_widget_id (a_id: STRING)
			-- Set widget identifier (procedure).
		require
			id_not_empty: not a_id.is_empty
		do
			widget_id := a_id
		ensure
			id_set: widget_id.same_string (a_id)
		end

	id (a_id: STRING): like Current
			-- Set widget identifier (fluent).
		require
			id_not_empty: not a_id.is_empty
		do
			set_widget_id (a_id)
			Result := Current
		ensure
			id_set: widget_id.same_string (a_id)
			result_is_current: Result = Current
		end

feature -- Status

	is_visible: BOOLEAN
			-- Is this widget visible?
		do
			Result := ev_widget.is_show_requested
		end

	is_enabled: BOOLEAN
			-- Is this widget enabled (sensitive)?
		do
			Result := ev_widget.is_sensitive
		end

	has_focus: BOOLEAN
			-- Does this widget have keyboard focus?
		do
			Result := ev_widget.has_focus
		end

feature -- Visibility

	show_now
			-- Make widget visible (procedure for statement use).
		do
			ev_widget.show
		ensure
			visible: is_visible
		end

	show: like Current
			-- Make widget visible (fluent).
		do
			show_now
			Result := Current
		ensure
			visible: is_visible
			result_is_current: Result = Current
		end

	hide_now
			-- Make widget invisible (procedure for statement use).
		do
			ev_widget.hide
		ensure
			not_visible: not is_visible
		end

	hide: like Current
			-- Make widget invisible (fluent).
		do
			hide_now
			Result := Current
		ensure
			not_visible: not is_visible
			result_is_current: Result = Current
		end

	visible (a_visible: BOOLEAN): like Current
			-- Set visibility.
		do
			if a_visible then
				Result := show
			else
				Result := hide
			end
		ensure
			result_is_current: Result = Current
		end

feature -- State

	enable: like Current
			-- Enable widget (make sensitive).
		do
			ev_widget.enable_sensitive
			Result := Current
		ensure
			enabled: is_enabled
			result_is_current: Result = Current
		end

	disable: like Current
			-- Disable widget (make insensitive).
		do
			ev_widget.disable_sensitive
			Result := Current
		ensure
			disabled: not is_enabled
			result_is_current: Result = Current
		end

	enabled (a_enabled: BOOLEAN): like Current
			-- Set enabled state.
		do
			if a_enabled then
				Result := enable
			else
				Result := disable
			end
		ensure
			result_is_current: Result = Current
		end

feature -- Layout Hints

	expansion_prevented: BOOLEAN
			-- Should this widget NOT expand when placed in a box container?
			-- Default is False (widgets expand to fill available space).

	is_expandable: BOOLEAN
			-- Should this widget expand when placed in a box container?
			-- This is the inverse of expansion_prevented.
		do
			Result := not expansion_prevented
		end

feature -- Layout Hint Commands

	set_expansion_prevented (a_value: BOOLEAN)
			-- Set whether this widget should be prevented from expanding.
		do
			expansion_prevented := a_value
		ensure
			expansion_prevented_set: expansion_prevented = a_value
		end

feature -- Layout Hint Fluent

	no_expand,
	compact: like Current
			-- Fluent: mark this widget as non-expandable.
			-- Use when adding to a box to prevent stretching.
		do
			set_expansion_prevented (True)
			Result := Current
		ensure
			not_expandable: not is_expandable
			result_is_current: Result = Current
		end

	expandable: like Current
			-- Fluent: mark this widget as expandable (default).
		do
			set_expansion_prevented (False)
			Result := Current
		ensure
			is_expandable_now: is_expandable
			result_is_current: Result = Current
		end

feature -- Sizing

	set_minimum_size (a_width, a_height: INTEGER): like Current
			-- Set minimum size.
		require
			valid_width: a_width >= 0
			valid_height: a_height >= 0
		do
			ev_widget.set_minimum_size (a_width, a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_minimum_width (a_width: INTEGER): like Current
			-- Set minimum width.
		require
			valid_width: a_width >= 0
		do
			ev_widget.set_minimum_width (a_width)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_minimum_height (a_height: INTEGER): like Current
			-- Set minimum height.
		require
			valid_height: a_height >= 0
		do
			ev_widget.set_minimum_height (a_height)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	min_width (a_width: INTEGER): like Current
			-- Fluent alias for set_minimum_width.
		require
			valid_width: a_width >= 0
		do
			Result := set_minimum_width (a_width)
		ensure
			result_is_current: Result = Current
		end

	min_height (a_height: INTEGER): like Current
			-- Fluent alias for set_minimum_height.
		require
			valid_height: a_height >= 0
		do
			Result := set_minimum_height (a_height)
		ensure
			result_is_current: Result = Current
		end

	width (a_width: INTEGER): like Current
			-- Set minimum width (fluent).
		require
			valid_width: a_width >= 0
		do
			Result := set_minimum_width (a_width)
		ensure
			result_is_current: Result = Current
		end

	height (a_height: INTEGER): like Current
			-- Set minimum height (fluent).
		require
			valid_height: a_height >= 0
		do
			Result := set_minimum_height (a_height)
		ensure
			result_is_current: Result = Current
		end

feature -- Focus

	set_focus: like Current
			-- Request keyboard focus.
		do
			ev_widget.set_focus
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	focus: like Current
			-- Fluent alias for set_focus.
		do
			Result := set_focus
		ensure
			result_is_current: Result = Current
		end

feature {SV_TEST_HARNESS} -- Instrumentation (W_code-style hooks)

	test_harness: detachable SV_TEST_HARNESS
			-- Attached test harness (like debugger attachment).
			-- When Void, instrumentation has zero overhead.

	attach_harness (a_harness: SV_TEST_HARNESS)
			-- Attach test harness to this widget.
		require
			harness_attached: a_harness /= Void
		do
			test_harness := a_harness
		ensure
			harness_set: test_harness = a_harness
		end

	detach_harness
			-- Detach test harness.
		do
			test_harness := Void
		ensure
			detached: test_harness = Void
		end

	notify_event (a_event: SV_EVENT)
			-- Notify attached harness of widget event.
			-- No-op when harness not attached (zero overhead).
		require
			event_attached: a_event /= Void
		do
			if attached test_harness as h then
				h.record_event (Current, a_event)
			end
		end

	is_instrumented: BOOLEAN
			-- Is a test harness attached?
		do
			Result := test_harness /= Void
		end

end
