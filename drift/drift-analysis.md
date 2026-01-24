# Drift Analysis: simple_vision

Generated: 2026-01-24
Method: `ec.exe -flatshort` vs `specs/*.md` + `research/*.md`

## Specification Sources

| Source | Files | Lines |
|--------|-------|-------|
| specs/*.md | 8 | 945 |
| research/*.md | 0 | 0 |

## Classes Analyzed

| Class | Spec'd Features | Actual Features | Drift |
|-------|-----------------|-----------------|-------|
| SIMPLE_VISION | 36 | 0 | -36 |

## Feature-Level Drift

### Specified, Implemented ✓
- (none matched)

### Specified, NOT Implemented ✗
- `canvas_empty` ✗
- `color_picker` ✗
- `credit_card_field` ✗
- `currency_field` ✗
- `data_grid` ✗
- `date_field` ✗
- `date_field_iso` ✗
- `decimal_field` ✗
- `decrease_ui_scale` ✗
- `divider_vertical` ✗
- ... and 26 more

### Implemented, NOT Specified
- (none)

## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 0 |
| Spec'd, missing | 36 |
| Implemented, not spec'd | 0 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_vision** has high drift. Significant gaps between spec and implementation.
