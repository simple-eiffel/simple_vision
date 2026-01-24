# S05 - Constraints: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Date:** 2026-01-23

## Widget Constraints

### Dimension Constraints
```eiffel
-- All sized widgets
width > 0
height > 0

-- Slider/SpinBox ranges
min < max

-- Grid dimensions
columns > 0
rows > 0
```

### Color Constraints
```eiffel
-- RGB values
0 <= red <= 255
0 <= green <= 255
0 <= blue <= 255

-- Hex format
0x000000 to 0xFFFFFF
```

### Scale Constraints
```eiffel
-- UI scaling
0.5 <= scale <= 3.0
Default: 1.0 (100%)
```

## Form Validation Rules

### Required Rule
- Field must not be empty
- Whitespace-only counts as empty

### Length Rules
```eiffel
min_length >= 0
max_length >= min_length
content.count >= min_length
content.count <= max_length
```

### Range Rule
```eiffel
min <= value <= max
-- For numeric fields only
```

### Pattern Rule
- Regex pattern matching
- POSIX extended regex syntax

### Email Rule
- Standard email format
- local@domain pattern

## State Machine Constraints

### State Constraints
- State names must be unique within machine
- Initial state must exist
- At least one state required

### Transition Constraints
- From state must exist
- To state must exist
- Event names should be unique per from-state

## Masked Field Patterns

| Field Type | Pattern | Example |
|------------|---------|---------|
| Phone (US) | (###) ###-#### | (555) 123-4567 |
| SSN | ###-##-#### | 123-45-6789 |
| Date (US) | ##/##/#### | 12/31/2025 |
| Date (ISO) | ####-##-## | 2025-12-31 |
| ZIP (US) | ##### | 12345 |
| Credit Card | #### #### #### #### | 1234 5678 9012 3456 |
| IPv4 | ###.###.###.### | 192.168.1.1 |
| Time (24h) | ##:## | 23:59 |

## Graphics Constraints

### Canvas Constraints
```eiffel
width > 0
height > 0
-- Memory: width * height * 4 bytes (RGBA)
```

### Waveform Constraints
```eiffel
width > 0
height > 0
-- Sample data: ARRAY [REAL_32]
-- Values normalized: -1.0 to 1.0
```

## Platform Constraints

### Windows
- Requires EiffelVision2 (EV_*)
- Cairo for graphics features
- GTK alternative (future)

### Dependencies
- simple_json for state machine JSON
- simple_decimal for decimal fields
- simple_cairo for drawing
- simple_stb for image loading
