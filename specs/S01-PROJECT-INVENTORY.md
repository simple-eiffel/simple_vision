# S01 - Project Inventory: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Version:** Phase 7 (Production)
**Date:** 2026-01-23

## Overview

Modern GUI toolkit for Eiffel with fluent APIs, theming, forms, state machines, and Cairo graphics. Provides a comprehensive widget library built on EiffelVision2.

## Project Files

### Core Source Files
| File | Purpose |
|------|---------|
| `src/core/sv_application.e` | Application lifecycle |
| `src/core/sv_quick.e` | Fluent widget factory |
| `src/core/sv_any.e` | Base class |

### Container Source Files
| File | Purpose |
|------|---------|
| `src/containers/sv_window.e` | Main window |
| `src/containers/sv_box.e` | Base container |
| `src/containers/sv_row.e` | Horizontal layout |
| `src/containers/sv_column.e` | Vertical layout |
| `src/containers/sv_container.e` | Container base |

### Widget Source Files
| File | Purpose |
|------|---------|
| `src/widgets/sv_text.e` | Text label |
| `src/widgets/sv_button.e` | Button |
| `src/widgets/sv_text_field.e` | Text input |
| `src/widgets/sv_password_field.e` | Password input |
| `src/widgets/sv_checkbox.e` | Checkbox |
| `src/widgets/sv_radio_group.e` | Radio buttons |
| `src/widgets/sv_dropdown.e` | Dropdown/combobox |
| `src/widgets/sv_list.e` | List widget |
| `src/widgets/sv_slider.e` | Slider |
| `src/widgets/sv_progress_bar.e` | Progress bar |
| `src/widgets/sv_spin_box.e` | Numeric spinner |
| `src/widgets/sv_tree.e` | Tree widget |
| `src/widgets/sv_data_grid.e` | Data table |
| `src/widgets/sv_decimal_field.e` | Decimal input |
| `src/widgets/sv_masked_field.e` | Masked input |

### Form and State Source Files
| File | Purpose |
|------|---------|
| `src/forms/sv_form.e` | Form container |
| `src/forms/sv_field.e` | Form field |
| `src/forms/sv_validation_rule.e` | Validation base |
| `src/state/sv_state_machine.e` | State machine |
| `src/state/sv_state.e` | State definition |

### Graphics Source Files
| File | Purpose |
|------|---------|
| `src/graphics/sv_cairo_canvas.e` | Cairo drawing |
| `src/graphics/sv_waveform.e` | Waveform display |

### Styling Source Files
| File | Purpose |
|------|---------|
| `src/styling/sv_theme.e` | Theme management |
| `src/styling/sv_color.e` | Color representation |

### Configuration Files
| File | Purpose |
|------|---------|
| `simple_vision.ecf` | EiffelStudio project configuration |
| `simple_vision.rc` | Windows resource file |

## Dependencies

### ISE Libraries
- base (core Eiffel classes)
- vision2 (EiffelVision2)

### simple_* Libraries
- simple_json (state machine JSON)
- simple_decimal (decimal fields)
- simple_cairo (Cairo graphics)
- simple_stb (image loading)

## Build Targets
- `simple_vision` - Main library
- `simple_vision_tests` - Test suite
- `simple_vision_demos` - Demo applications
