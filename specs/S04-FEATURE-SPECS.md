# S04 - Feature Specifications: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Date:** 2026-01-23

## SV_QUICK Factory Features

### Windows
| Feature | Result | Description |
|---------|--------|-------------|
| `window (title)` | SV_WINDOW | Main window |

### Containers
| Feature | Result | Description |
|---------|--------|-------------|
| `row` | SV_ROW | Horizontal box |
| `column` | SV_COLUMN | Vertical box |
| `hbox` | SV_ROW | Alias for row |
| `vbox` | SV_COLUMN | Alias for column |
| `row_of (widgets)` | SV_ROW | Row with children |
| `column_of (widgets)` | SV_COLUMN | Column with children |
| `grid` | SV_GRID | Grid layout |
| `grid_sized (cols, rows)` | SV_GRID | Sized grid |
| `stack` | SV_STACK | Absolute positioning |
| `tabs` | SV_TAB_PANEL | Tab panel |
| `horizontal_splitter` | SV_SPLITTER | Left/right split |
| `vertical_splitter` | SV_SPLITTER | Top/bottom split |
| `card` | SV_CARD | Bordered panel |
| `card_titled (title)` | SV_CARD | Panel with title |
| `scroll` | SV_SCROLL | Scrollable area |

### Basic Widgets
| Feature | Result | Description |
|---------|--------|-------------|
| `text (content)` | SV_TEXT | Text label |
| `label (content)` | SV_TEXT | Alias |
| `button (label)` | SV_BUTTON | Clickable button |
| `text_field` | SV_TEXT_FIELD | Text input |
| `text_input (initial)` | SV_TEXT_FIELD | With initial value |
| `checkbox (label)` | SV_CHECKBOX | Toggle checkbox |
| `radio_group` | SV_RADIO_GROUP | Radio buttons |
| `radios (options)` | SV_RADIO_GROUP | With options |
| `dropdown` | SV_DROPDOWN | Dropdown |
| `dropdown_with (options)` | SV_DROPDOWN | With options |
| `list` | SV_LIST | List widget |
| `list_with (items)` | SV_LIST | With items |
| `slider` | SV_SLIDER | Range slider |
| `slider_range (min, max)` | SV_SLIDER | With range |
| `progress` | SV_PROGRESS_BAR | Progress bar |
| `spin_box` | SV_SPIN_BOX | Numeric spinner |
| `spin_box_range (min, max)` | SV_SPIN_BOX | With range |
| `tree` | SV_TREE | Tree widget |
| `tree_with (roots)` | SV_TREE | With root items |

### Masked Input Fields
| Feature | Result | Description |
|---------|--------|-------------|
| `masked_field` | SV_MASKED_FIELD | Generic masked |
| `phone_field` | SV_MASKED_FIELD | US phone |
| `email_field` | SV_MASKED_FIELD | Email address |
| `date_field` | SV_MASKED_FIELD | US date MM/DD/YYYY |
| `date_field_iso` | SV_MASKED_FIELD | ISO YYYY-MM-DD |
| `credit_card_field` | SV_MASKED_FIELD | Credit card |
| `ssn_field` | SV_MASKED_FIELD | SSN |
| `zip_code_field` | SV_MASKED_FIELD | US ZIP |
| `ip_address_field` | SV_MASKED_FIELD | IPv4 |
| `time_field` | SV_MASKED_FIELD | 24-hour HH:MM |

### Data Widgets
| Feature | Result | Description |
|---------|--------|-------------|
| `data_grid` | SV_DATA_GRID | Data table |
| `data_grid_with (cols)` | SV_DATA_GRID | With columns |
| `decimal_field` | SV_DECIMAL_FIELD | Decimal input |
| `currency_field` | SV_DECIMAL_FIELD | Currency (2 decimals) |

### Application Chrome
| Feature | Result | Description |
|---------|--------|-------------|
| `menu_bar` | SV_MENU_BAR | Menu bar |
| `menu (title)` | SV_MENU | Menu |
| `menu_item (label)` | SV_MENU_ITEM | Menu item |
| `toolbar` | SV_TOOLBAR | Toolbar |
| `toolbar_button (label)` | SV_TOOLBAR_BUTTON | Toolbar button |
| `statusbar` | SV_STATUSBAR | Status bar |
| `statusbar_with (text)` | SV_STATUSBAR | With initial text |

### Dialogs
| Feature | Result | Description |
|---------|--------|-------------|
| `dialog` | SV_DIALOG | Empty dialog |
| `dialog_with_title (title)` | SV_DIALOG | Titled dialog |
| `open_file_dialog` | SV_FILE_DIALOG | File open |
| `save_file_dialog` | SV_FILE_DIALOG | File save |
| `info_box (msg)` | SV_MESSAGE_BOX | Info message |
| `warning_box (msg)` | SV_MESSAGE_BOX | Warning |
| `error_box (msg)` | SV_MESSAGE_BOX | Error |
| `question_box (msg)` | SV_MESSAGE_BOX | Yes/No |
| `confirm_box (msg)` | SV_MESSAGE_BOX | OK/Cancel |
| `color_picker` | SV_COLOR_PICKER | Color selection |
| `font_picker` | SV_FONT_PICKER | Font selection |

### Layout Helpers
| Feature | Result | Description |
|---------|--------|-------------|
| `spacer` | SV_SPACER | Flexible space |
| `spacer_fixed (size)` | SV_SPACER | Fixed space |
| `separator_horizontal` | SV_SEPARATOR | H-line |
| `separator_vertical` | SV_SEPARATOR | V-line |
| `divider` | SV_DIVIDER | Themed H-line |
| `divider_vertical` | SV_DIVIDER | Themed V-line |

### Forms
| Feature | Result | Description |
|---------|--------|-------------|
| `form` | SV_FORM | Form container |
| `field (name)` | SV_FIELD | Form field |

### State Machines
| Feature | Result | Description |
|---------|--------|-------------|
| `state_machine (name)` | SV_STATE_MACHINE | New machine |
| `state_machine_from_json (json)` | SV_STATE_MACHINE | From JSON |
| `state_machine_from_file (path)` | SV_STATE_MACHINE | From file |

### Graphics
| Feature | Result | Description |
|---------|--------|-------------|
| `canvas (w, h)` | SV_CAIRO_CANVAS | Drawing canvas |
| `canvas_empty` | SV_CAIRO_CANVAS | Default size |
| `waveform (w, h)` | SV_WAVEFORM | Waveform display |
| `waveform_default` | SV_WAVEFORM | Default size |
| `image` | SV_IMAGE | Empty image |
| `image_from (path)` | SV_IMAGE | From file |

### Theming
| Feature | Result | Description |
|---------|--------|-------------|
| `set_dark_mode (dark)` | | Toggle dark mode |
| `toggle_dark_mode` | | Toggle |
| `set_color_scheme (name)` | | Color scheme |
| `set_ui_scale (scale)` | | UI scaling |
| `increase_ui_scale` | | Zoom in |
| `decrease_ui_scale` | | Zoom out |
| `reset_ui_scale` | | Reset to 100% |
