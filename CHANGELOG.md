# Changelog

All notable changes to simple_vision are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project does not carry a version number yet, so this entry is under Unreleased.

## [Unreleased]

### Fixed
- `SV_THEME`: `theme_mode`, `ui_scale` and `base_font_points` were attributes with bodies on expanded types,
  which the compiler never runs (VWAB x3 in every target). They are plain attributes now, initialised in
  `make_internal`.
- `demo_theme`: the radio-group handler takes `STRING_32`, as `SV_RADIO_GROUP.on_change` requires (VUAR).
- `demo_cairo`: the fluent waveform chain is assigned back to `demo_waveform` (VKCN), and the sine waves use
  `DOUBLE_MATH` (VEEN x3).
- `demo_state_machine`: `set_initial` is a procedure, so the trailing `.do_nothing` is gone (VKCN).
- `demo_form`: removed an unused local.
