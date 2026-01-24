# S06 - Boundaries: simple_vision

**Document Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_vision
**Date:** 2026-01-23

## Scope Boundaries

### In Scope
- Window management
- Comprehensive widget library (50+ widgets)
- Container layouts (row, column, grid, stack, tabs, splitter)
- Form validation with rules
- State machine support (programmatic and JSON)
- Theming (dark mode, color schemes, scaling)
- Cairo graphics (canvas, waveform)
- Application chrome (menus, toolbars, status bars)
- Standard dialogs (file, message, color, font)
- Masked input fields (phone, email, date, etc.)

### Out of Scope
- **Custom rendering** - Uses EiffelVision2 natives
- **3D graphics** - 2D only via Cairo
- **Animation framework** - Manual updates
- **Data binding** - Manual widget updates
- **Drag and drop** - Basic support via EV2
- **Accessibility** - Inherits from EV2
- **Mobile platforms** - Desktop only
- **Web deployment** - Native only

## API Boundaries

### Public API (SV_QUICK factory)
- All widget creation methods
- Theme configuration
- Form creation
- State machine creation
- Graphics creation

### Internal API (not exported)
- EiffelVision2 wrapping
- Theme calculation
- Layout algorithms

## Integration Boundaries

### Input Boundaries

| Input Type | Format | Validation |
|------------|--------|------------|
| Titles/Labels | STRING | Any string |
| Dimensions | INTEGER | > 0 |
| Colors | INTEGER (RGB) | 0-255 per channel |
| Scale | REAL | 0.5 to 3.0 |
| Options | ARRAY [STRING] | Non-void |
| JSON | STRING | Valid JSON |

### Output Boundaries

| Output Type | Format | Notes |
|-------------|--------|-------|
| Widgets | SV_WIDGET | Non-void |
| Dialog results | BOOLEAN/STRING | Varies by dialog |
| State | STRING | Current state name |

## Performance Boundaries

### Expected Performance

| Operation | Time | Notes |
|-----------|------|-------|
| Widget create | < 1 ms | Allocation |
| Layout | < 10 ms | Per resize |
| Render | < 16 ms | 60fps target |
| Theme switch | < 100 ms | Full repaint |

### Resource Usage

| Resource | Typical | Maximum |
|----------|---------|---------|
| Memory per widget | ~1-5 KB | Varies |
| Canvas memory | width*height*4 | Configurable |
| State machine | ~10 KB | Varies by complexity |

## Extension Points

### Custom Widgets
1. Inherit from SV_WIDGET
2. Implement required features
3. Use via direct instantiation

### Custom Validation Rules
1. Inherit from SV_VALIDATION_RULE
2. Override `is_valid` feature
3. Add to form field

### Custom Themes
- Not yet extensible
- Future: theme definition files

## Dependency Boundaries

### Required Dependencies
- EiffelBase
- EiffelVision2

### Optional Dependencies
- simple_json (state machines from JSON)
- simple_decimal (decimal fields)
- simple_cairo (canvas, waveform)
- simple_stb (image loading)
