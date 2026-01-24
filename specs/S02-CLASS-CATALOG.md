# S02 - Class Catalog: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Date:** 2026-01-23

## Class Hierarchy

```
SV_ANY (base)
|
+-- SV_APPLICATION
|
+-- SV_QUICK (factory)
|
+-- SV_WIDGET (deferred)
|   +-- SV_CONTAINER
|   |   +-- SV_WINDOW
|   |   +-- SV_BOX
|   |   |   +-- SV_ROW
|   |   |   +-- SV_COLUMN
|   |   +-- SV_GRID
|   |   +-- SV_STACK
|   |   +-- SV_TAB_PANEL
|   |   +-- SV_SPLITTER
|   |   +-- SV_CARD
|   |   +-- SV_SCROLL
|   |
|   +-- Basic Widgets
|   |   +-- SV_TEXT
|   |   +-- SV_BUTTON
|   |   +-- SV_CHECKBOX
|   |   +-- SV_RADIO_GROUP
|   |   +-- SV_DROPDOWN
|   |   +-- SV_LIST
|   |   +-- SV_SLIDER
|   |   +-- SV_PROGRESS_BAR
|   |   +-- SV_SPIN_BOX
|   |   +-- SV_IMAGE
|   |
|   +-- Input Widgets
|   |   +-- SV_TEXT_FIELD
|   |   +-- SV_PASSWORD_FIELD
|   |   +-- SV_DECIMAL_FIELD
|   |   +-- SV_MASKED_FIELD
|   |
|   +-- Data Widgets
|   |   +-- SV_DATA_GRID
|   |   +-- SV_TREE
|   |
|   +-- Application Chrome
|       +-- SV_MENU_BAR
|       +-- SV_MENU
|       +-- SV_MENU_ITEM
|       +-- SV_TOOLBAR
|       +-- SV_TOOLBAR_BUTTON
|       +-- SV_STATUSBAR
|       +-- SV_DIALOG
|       +-- SV_MESSAGE_BOX
|       +-- SV_FILE_DIALOG
|       +-- SV_COLOR_PICKER
|       +-- SV_FONT_PICKER
|
+-- Layout Helpers
|   +-- SV_SPACER
|   +-- SV_SEPARATOR
|   +-- SV_DIVIDER
|
+-- Forms
|   +-- SV_FORM
|   +-- SV_FIELD
|   +-- SV_VALIDATION_RULE
|       +-- SV_REQUIRED_RULE
|       +-- SV_MIN_LENGTH_RULE
|       +-- SV_MAX_LENGTH_RULE
|       +-- SV_RANGE_RULE
|       +-- SV_PATTERN_RULE
|       +-- SV_EMAIL_RULE
|
+-- State
|   +-- SV_STATE_MACHINE
|   +-- SV_STATE
|   +-- SV_TRANSITION
|
+-- Graphics
|   +-- SV_CAIRO_CANVAS
|   +-- SV_WAVEFORM
|
+-- Styling
    +-- SV_THEME
    +-- SV_COLOR
```

## Class Count Summary
- Core: 3
- Containers: 10
- Basic Widgets: 11
- Input Widgets: 4
- Data Widgets: 2
- Application Chrome: 11
- Layout Helpers: 3
- Forms: 8
- State: 3
- Graphics: 2
- Styling: 2
- **Total: 59+ classes**
