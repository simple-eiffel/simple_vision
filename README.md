<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_vision

**[Documentation](https://simple-eiffel.github.io/simple_vision/)** | **[GitHub](https://github.com/simple-eiffel/simple_vision)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

**Modern GUI toolkit for Eiffel** with fluent APIs, theming, forms, state machines, and Cairo graphics.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Production** - Phase 7 complete, comprehensive widget library with tests

## Features

- **Fluent API** - Chainable widget construction with modern naming
- **Rich Widgets** - Buttons, text fields, checkboxes, radio groups, dropdowns, lists, sliders, progress bars
- **Containers** - Rows, columns, grids, stacks, tabs, splitters, cards, scroll areas
- **Application Chrome** - Menu bars, toolbars, status bars, dialogs
- **Standard Dialogs** - File open/save, message boxes, color/font pickers
- **Data Widgets** - Data grids, decimal fields, masked input fields
- **Form Validation** - Required, min/max length, range, email, pattern rules
- **State Machines** - Declarative UI state management with JSON support
- **Theming** - Dark mode, color schemes, UI scaling
- **Cairo Graphics** - Custom drawing, waveform visualization

## Installation

### Prerequisites

- EiffelStudio 25.02 or later
- EiffelVision2 library
- Optional: Cairo library for graphics features
- Optional: simple_cairo, simple_stb for advanced graphics

### Add to Your ECF

```xml
<library name="simple_vision" location="$SIMPLE_EIFFEL/simple_vision/simple_vision.ecf"/>
```

## Quick Start

```eiffel
class
    MY_APP

inherit
    SV_APPLICATION

create
    make_and_launch

feature {NONE} -- Initialization

    make_and_launch
        do
            default_create
            launch
        end

    build_main_window
        local
            sv: SV_QUICK
        do
            create sv.make
            main_window := sv.window ("My App")
                .sized (400, 300)
                .child (
                    sv.column_of (<<
                        sv.text ("Hello, simple_vision!"),
                        sv.button ("Click Me").on_click (agent handle_click)
                    >>)
                    .padding (20)
                    .spacing (10)
                )
        end

    handle_click
        do
            print ("Button clicked!%N")
        end

end
```

## Widget Factory (SV_QUICK)

```eiffel
local
    sv: SV_QUICK
do
    create sv.make

    -- Windows
    sv.window ("Title")

    -- Containers
    sv.row                              -- Horizontal box
    sv.column                           -- Vertical box
    sv.row_of (<<widget1, widget2>>)    -- Row with children
    sv.column_of (<<widget1, widget2>>) -- Column with children
    sv.grid                             -- Grid layout
    sv.stack                            -- Absolute positioning
    sv.tabs                             -- Tab panel
    sv.horizontal_splitter              -- Left/right split
    sv.vertical_splitter                -- Top/bottom split
    sv.card                             -- Bordered panel
    sv.scroll                           -- Scrollable area

    -- Basic Widgets
    sv.text ("Label text")
    sv.button ("Click Me")
    sv.text_field
    sv.password_field
    sv.checkbox ("Enable feature")
    sv.radios (<<"Option 1", "Option 2">>)
    sv.dropdown_with (<<"Choice A", "Choice B">>)
    sv.list_with (<<"Item 1", "Item 2">>)

    -- Range Widgets
    sv.slider_range (0, 100)
    sv.progress
    sv.spin_box_range (1, 10)

    -- Masked Input Fields
    sv.phone_field
    sv.email_field
    sv.date_field
    sv.credit_card_field
    sv.ssn_field
    sv.zip_code_field
    sv.ip_address_field
    sv.time_field

    -- Data Widgets
    sv.data_grid_with (<<"Name", "Value">>)
    sv.decimal_field
    sv.currency_field
    sv.tree

    -- Application Chrome
    sv.menu_bar
    sv.menu ("File")
    sv.menu_item ("Open")
    sv.toolbar
    sv.statusbar_with ("Ready")

    -- Dialogs
    sv.open_file_dialog
    sv.save_file_dialog
    sv.info_box ("Information message")
    sv.warning_box ("Warning message")
    sv.error_box ("Error message")
    sv.question_box ("Are you sure?")
    sv.color_picker
    sv.font_picker

    -- Graphics (Phase 7)
    sv.canvas (400, 300)
    sv.waveform (300, 100)
end
```

## Form Validation

```eiffel
local
    sv: SV_QUICK
    my_form: SV_FORM
do
    create sv.make

    my_form := sv.form
        .add_field (sv.field ("username")
            .widget (sv.text_field)
            .required
            .min_length (3)
            .max_length (20))
        .add_field (sv.field ("email")
            .widget (sv.email_field)
            .required)
        .add_field (sv.field ("age")
            .widget (sv.spin_box_range (18, 120))
            .range (18, 120))
        .on_valid (agent handle_submit)
end
```

## State Machines

```eiffel
local
    sv: SV_QUICK
    machine: SV_STATE_MACHINE
do
    create sv.make

    -- Create programmatically
    machine := sv.state_machine ("auth")
    machine.state ("logged_out").described_as ("User not logged in").do_nothing
    machine.state ("logging_in").described_as ("Authentication in progress").do_nothing
    machine.state ("logged_in").described_as ("User authenticated").do_nothing

    machine.on ("login").from_state ("logged_out").to ("logging_in").apply.do_nothing
    machine.on ("success").from_state ("logging_in").to ("logged_in").apply.do_nothing
    machine.on ("failure").from_state ("logging_in").to ("logged_out").apply.do_nothing
    machine.on ("logout").from_state ("logged_in").to ("logged_out").apply.do_nothing

    machine.set_initial ("logged_out")

    -- Trigger transitions
    machine.trigger ("login")
    print ("Current state: " + machine.current_state.name + "%N")

    -- Or load from JSON file
    if attached sv.state_machine_from_file ("auth.json") as m then
        m.trigger ("login")
    end
end
```

## Theming

```eiffel
local
    sv: SV_QUICK
do
    create sv.make

    -- Dark mode
    sv.set_dark_mode (True)
    sv.toggle_dark_mode

    -- Color schemes
    sv.set_color_scheme ("blue")
    sv.set_color_scheme ("green")
    sv.set_color_scheme ("purple")

    -- UI scaling
    sv.set_ui_scale (1.25)  -- 125%
    sv.increase_ui_scale
    sv.decrease_ui_scale
    sv.reset_ui_scale
end
```

## Cairo Graphics (Phase 7)

```eiffel
local
    sv: SV_QUICK
    canvas: SV_CAIRO_CANVAS
do
    create sv.make

    -- Create drawing canvas
    canvas := sv.canvas (400, 300)
        .background_hex (0xFFFFFF)
        .on_draw (agent draw_content)

    -- Waveform display
    waveform := sv.waveform (300, 100)
        .foreground_hex (0x3498DB)
        .background_hex (0x2C3E50)
end

draw_content (a_context: CAIRO_CONTEXT)
    do
        a_context.set_color_hex (0x3498DB)
            .fill_rect (10, 10, 100, 50)
            .do_nothing
        a_context.set_color_hex (0xE74C3C)
            .stroke_circle (200, 150, 40)
            .do_nothing
    end
```

## API Classes

| Category | Classes |
|----------|---------|
| Core | SV_APPLICATION, SV_QUICK, SV_ANY |
| Windows | SV_WINDOW |
| Containers | SV_ROW, SV_COLUMN, SV_BOX, SV_GRID, SV_STACK, SV_TAB_PANEL, SV_SPLITTER, SV_CARD, SV_SCROLL |
| Basic Widgets | SV_TEXT, SV_BUTTON, SV_CHECKBOX, SV_RADIO_GROUP, SV_DROPDOWN, SV_LIST, SV_SLIDER, SV_PROGRESS_BAR, SV_SPIN_BOX |
| Input Fields | SV_TEXT_FIELD, SV_PASSWORD_FIELD, SV_DECIMAL_FIELD, SV_MASKED_FIELD |
| Data Widgets | SV_DATA_GRID, SV_TREE |
| Application | SV_MENU_BAR, SV_MENU, SV_MENU_ITEM, SV_TOOLBAR, SV_TOOLBAR_BUTTON, SV_STATUSBAR |
| Dialogs | SV_DIALOG, SV_FILE_DIALOG, SV_MESSAGE_BOX, SV_COLOR_PICKER, SV_FONT_PICKER |
| Layout | SV_SPACER, SV_SEPARATOR, SV_DIVIDER |
| Forms | SV_FORM, SV_FIELD, SV_VALIDATION_RULE |
| State | SV_STATE_MACHINE, SV_STATE, SV_TRANSITION |
| Graphics | SV_CAIRO_CANVAS, SV_WAVEFORM, SV_IMAGE |
| Styling | SV_THEME, SV_COLOR, SV_TOKENS |

## Dependencies

- EiffelVision2 (EV_*)
- simple_json (for state machine JSON loading)
- simple_decimal (for decimal fields)
- simple_cairo (for Cairo graphics features)
- simple_stb (for image loading)

## License

MIT License - See LICENSE file

---

Part of the **Simple Eiffel** ecosystem.
