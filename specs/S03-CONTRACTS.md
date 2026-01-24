# S03 - Contracts: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Date:** 2026-01-23

## SV_QUICK Contracts

### Window Creation

```eiffel
window (a_title: READABLE_STRING_GENERAL): SV_WINDOW
    require
        title_not_empty: not a_title.is_empty
    ensure
        result_attached: Result /= Void
```

### Container Creation

```eiffel
row: SV_ROW
    ensure
        result_attached: Result /= Void

column: SV_COLUMN
    ensure
        result_attached: Result /= Void

row_of (a_widgets: ARRAY [SV_WIDGET]): SV_ROW
    require
        widgets_attached: a_widgets /= Void
    ensure
        result_attached: Result /= Void

column_of (a_widgets: ARRAY [SV_WIDGET]): SV_COLUMN
    require
        widgets_attached: a_widgets /= Void
    ensure
        result_attached: Result /= Void
```

### Widget Creation

```eiffel
text (a_content: READABLE_STRING_GENERAL): SV_TEXT
    require
        content_not_void: a_content /= Void
    ensure
        result_attached: Result /= Void

button (a_label: READABLE_STRING_GENERAL): SV_BUTTON
    require
        label_not_empty: not a_label.is_empty
    ensure
        result_attached: Result /= Void

checkbox (a_label: READABLE_STRING_GENERAL): SV_CHECKBOX
    require
        label_not_void: a_label /= Void
    ensure
        result_attached: Result /= Void

slider_range (a_min, a_max: INTEGER): SV_SLIDER
    require
        valid_range: a_min < a_max
    ensure
        result_attached: Result /= Void

spin_box_range (a_min, a_max: INTEGER): SV_SPIN_BOX
    require
        valid_range: a_min < a_max
    ensure
        result_attached: Result /= Void
```

### Masked Field Creation

```eiffel
masked_field_with (a_pattern: READABLE_STRING_GENERAL): SV_MASKED_FIELD
    require
        pattern_attached: a_pattern /= Void
    ensure
        result_attached: Result /= Void
```

### Dialog Creation

```eiffel
info_box (a_message: STRING): SV_MESSAGE_BOX
    require
        message_not_empty: not a_message.is_empty
    ensure
        result_attached: Result /= Void

color_picker_with (a_red, a_green, a_blue: INTEGER): SV_COLOR_PICKER
    require
        valid_red: a_red >= 0 and a_red <= 255
        valid_green: a_green >= 0 and a_green <= 255
        valid_blue: a_blue >= 0 and a_blue <= 255
    ensure
        result_attached: Result /= Void
```

### Form Creation

```eiffel
field (a_name: STRING): SV_FIELD
    require
        name_not_empty: not a_name.is_empty
    ensure
        result_attached: Result /= Void
```

### State Machine

```eiffel
state_machine (a_name: STRING): SV_STATE_MACHINE
    require
        name_not_empty: not a_name.is_empty
    ensure
        result_attached: Result /= Void

state_machine_from_json (a_json: STRING): detachable SV_STATE_MACHINE
    require
        json_not_empty: not a_json.is_empty
```

### Graphics

```eiffel
canvas (a_width, a_height: INTEGER): SV_CAIRO_CANVAS
    require
        valid_width: a_width > 0
        valid_height: a_height > 0
    ensure
        result_attached: Result /= Void

waveform (a_width, a_height: INTEGER): SV_WAVEFORM
    require
        valid_width: a_width > 0
        valid_height: a_height > 0
    ensure
        result_attached: Result /= Void
```

### Theming

```eiffel
set_ui_scale (a_scale: REAL)
    require
        valid_scale: a_scale >= 0.5 and a_scale <= 3.0
```
