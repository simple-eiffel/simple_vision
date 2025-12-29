note
	description: "Factory class for fluent widget construction"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_QUICK

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Create factory.
		do
		end

feature -- Windows

	window (a_title: READABLE_STRING_GENERAL): SV_WINDOW
			-- Create a window with title.
		require
			title_not_empty: not a_title.is_empty
		do
			create Result.make_with_title (a_title)
		ensure
			result_attached: Result /= Void
		end

feature -- Containers (Modern names)

	row: SV_ROW
			-- Create a horizontal box (row).
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	column: SV_COLUMN
			-- Create a vertical box (column).
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

feature -- Containers (Classic aliases for EV2 veterans)

	hbox: SV_ROW
			-- Create a horizontal box (EV2 name).
		do
			Result := row
		ensure
			result_attached: Result /= Void
		end

	vbox: SV_COLUMN
			-- Create a vertical box (EV2 name).
		do
			Result := column
		ensure
			result_attached: Result /= Void
		end

feature -- Basic Widgets

	text (a_content: READABLE_STRING_GENERAL): SV_TEXT
			-- Create a text label.
		require
			content_not_void: a_content /= Void
		do
			create Result.make_with_text (a_content)
		ensure
			result_attached: Result /= Void
		end

	label (a_content: READABLE_STRING_GENERAL): SV_TEXT
			-- Create a label (alias for text).
		require
			content_not_void: a_content /= Void
		do
			Result := text (a_content)
		ensure
			result_attached: Result /= Void
		end

	button (a_label: READABLE_STRING_GENERAL): SV_BUTTON
			-- Create a button.
		require
			label_not_empty: not a_label.is_empty
		do
			create Result.make_with_text (a_label)
		ensure
			result_attached: Result /= Void
		end

feature -- Input Widgets

	text_field: SV_TEXT_FIELD
			-- Create empty text field.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	input: SV_TEXT_FIELD
			-- Create empty text field (alias).
		do
			Result := text_field
		ensure
			result_attached: Result /= Void
		end

	text_input (a_initial: READABLE_STRING_GENERAL): SV_TEXT_FIELD
			-- Create text field with initial text.
		require
			initial_not_void: a_initial /= Void
		do
			create Result.make_with_text (a_initial)
		ensure
			result_attached: Result /= Void
		end

feature -- Selection Widgets

	checkbox (a_label: READABLE_STRING_GENERAL): SV_CHECKBOX
			-- Create checkbox with label.
		require
			label_not_void: a_label /= Void
		do
			create Result.make_with_text (a_label)
		ensure
			result_attached: Result /= Void
		end

	radio_group: SV_RADIO_GROUP
			-- Create empty radio button group.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	radios (a_options: ARRAY [STRING]): SV_RADIO_GROUP
			-- Create radio group with options.
		require
			options_attached: a_options /= Void
			options_not_empty: not a_options.is_empty
		do
			create Result.make_with_options (a_options)
		ensure
			result_attached: Result /= Void
		end

	dropdown: SV_DROPDOWN
			-- Create empty dropdown.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	dropdown_with (a_options: ARRAY [STRING]): SV_DROPDOWN
			-- Create dropdown with options.
		require
			options_attached: a_options /= Void
		do
			create Result.make_with_options (a_options)
		ensure
			result_attached: Result /= Void
		end

	combo_box: SV_DROPDOWN
			-- Create dropdown (EV2 alias).
		do
			Result := dropdown
		ensure
			result_attached: Result /= Void
		end

	list: SV_LIST
			-- Create empty list.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	list_with (a_items: ARRAY [STRING]): SV_LIST
			-- Create list with items.
		require
			items_attached: a_items /= Void
		do
			create Result.make_with_items (a_items)
		ensure
			result_attached: Result /= Void
		end

feature -- Convenience: Row/Column with children

	row_of (a_widgets: ARRAY [SV_WIDGET]): SV_ROW
			-- Create row with children.
		require
			widgets_attached: a_widgets /= Void
		do
			create Result.make
			Result := Result.children (a_widgets)
		ensure
			result_attached: Result /= Void
		end

	column_of (a_widgets: ARRAY [SV_WIDGET]): SV_COLUMN
			-- Create column with children.
		require
			widgets_attached: a_widgets /= Void
		do
			create Result.make
			Result := Result.children (a_widgets)
		ensure
			result_attached: Result /= Void
		end

feature -- Range Widgets

	slider: SV_SLIDER
			-- Create slider with default range 0-100.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	slider_range (a_min, a_max: INTEGER): SV_SLIDER
			-- Create slider with specified range.
		require
			valid_range: a_min < a_max
		do
			create Result.make_with_range (a_min, a_max)
		ensure
			result_attached: Result /= Void
		end

	progress: SV_PROGRESS_BAR
			-- Create progress bar with default range 0-100.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	progress_bar: SV_PROGRESS_BAR
			-- Create progress bar (alias).
		do
			Result := progress
		ensure
			result_attached: Result /= Void
		end

	spin_box: SV_SPIN_BOX
			-- Create spin box with default range 0-100.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	spin_box_range (a_min, a_max: INTEGER): SV_SPIN_BOX
			-- Create spin box with specified range.
		require
			valid_range: a_min < a_max
		do
			create Result.make_with_range (a_min, a_max)
		ensure
			result_attached: Result /= Void
		end

	number_input: SV_SPIN_BOX
			-- Create numeric input (spin box alias).
		do
			Result := spin_box
		ensure
			result_attached: Result /= Void
		end

feature -- Container Widgets

	tabs: SV_TAB_PANEL
			-- Create empty tab panel.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	tab_panel: SV_TAB_PANEL
			-- Create empty tab panel (alias).
		do
			Result := tabs
		ensure
			result_attached: Result /= Void
		end

	notebook: SV_TAB_PANEL
			-- Create empty tab panel (EV2 name).
		do
			Result := tabs
		ensure
			result_attached: Result /= Void
		end

feature -- Hierarchical Widgets

	tree: SV_TREE
			-- Create empty tree.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	tree_with (a_roots: ARRAY [STRING]): SV_TREE
			-- Create tree with root items.
		require
			roots_attached: a_roots /= Void
		do
			create Result.make
			Result := Result.add_roots (a_roots)
		ensure
			result_attached: Result /= Void
		end

feature -- Application Chrome

	menu_bar: SV_MENU_BAR
			-- Create empty menu bar.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	menu (a_title: STRING): SV_MENU
			-- Create a menu with title.
		require
			title_not_empty: not a_title.is_empty
		do
			create Result.make (a_title)
		ensure
			result_attached: Result /= Void
		end

	menu_item (a_label: STRING): SV_MENU_ITEM
			-- Create a menu item.
		require
			label_not_empty: not a_label.is_empty
		do
			create Result.make (a_label)
		ensure
			result_attached: Result /= Void
		end

	toolbar: SV_TOOLBAR
			-- Create empty toolbar.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	toolbar_button (a_label: STRING): SV_TOOLBAR_BUTTON
			-- Create a toolbar button.
		require
			label_not_empty: not a_label.is_empty
		do
			create Result.make (a_label)
		ensure
			result_attached: Result /= Void
		end

	statusbar: SV_STATUSBAR
			-- Create empty status bar.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	statusbar_with (a_text: STRING): SV_STATUSBAR
			-- Create status bar with initial text.
		require
			text_not_void: a_text /= Void
		do
			create Result.make_with_text (a_text)
		ensure
			result_attached: Result /= Void
		end

	status_bar: SV_STATUSBAR
			-- Create empty status bar (alias).
		do
			Result := statusbar
		ensure
			result_attached: Result /= Void
		end

feature -- Dialogs

	dialog: SV_DIALOG
			-- Create empty dialog.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	dialog_with_title (a_title: STRING): SV_DIALOG
			-- Create dialog with title.
		require
			title_not_empty: not a_title.is_empty
		do
			create Result.make_with_title (a_title)
		ensure
			result_attached: Result /= Void
		end

feature -- Split Panes

	horizontal_splitter: SV_SPLITTER
			-- Create horizontal splitter (left/right).
		do
			create Result.make_horizontal
		ensure
			result_attached: Result /= Void
		end

	vertical_splitter: SV_SPLITTER
			-- Create vertical splitter (top/bottom).
		do
			create Result.make_vertical
		ensure
			result_attached: Result /= Void
		end

	hsplit: SV_SPLITTER
			-- Create horizontal splitter (alias).
		do
			Result := horizontal_splitter
		ensure
			result_attached: Result /= Void
		end

	vsplit: SV_SPLITTER
			-- Create vertical splitter (alias).
		do
			Result := vertical_splitter
		ensure
			result_attached: Result /= Void
		end

feature -- Standard Dialogs (Phase 5)

	open_file_dialog: SV_FILE_DIALOG
			-- Create file open dialog.
		do
			create Result.make_open
		ensure
			result_attached: Result /= Void
		end

	save_file_dialog: SV_FILE_DIALOG
			-- Create file save dialog.
		do
			create Result.make_save
		ensure
			result_attached: Result /= Void
		end

	file_open: SV_FILE_DIALOG
			-- Create file open dialog (alias).
		do
			Result := open_file_dialog
		ensure
			result_attached: Result /= Void
		end

	file_save: SV_FILE_DIALOG
			-- Create file save dialog (alias).
		do
			Result := save_file_dialog
		ensure
			result_attached: Result /= Void
		end

	info_box (a_message: STRING): SV_MESSAGE_BOX
			-- Create information message box.
		require
			message_not_empty: not a_message.is_empty
		do
			create Result.make_info (a_message)
		ensure
			result_attached: Result /= Void
		end

	warning_box (a_message: STRING): SV_MESSAGE_BOX
			-- Create warning message box.
		require
			message_not_empty: not a_message.is_empty
		do
			create Result.make_warning (a_message)
		ensure
			result_attached: Result /= Void
		end

	error_box (a_message: STRING): SV_MESSAGE_BOX
			-- Create error message box.
		require
			message_not_empty: not a_message.is_empty
		do
			create Result.make_error (a_message)
		ensure
			result_attached: Result /= Void
		end

	question_box (a_message: STRING): SV_MESSAGE_BOX
			-- Create yes/no question dialog.
		require
			message_not_empty: not a_message.is_empty
		do
			create Result.make_question (a_message)
		ensure
			result_attached: Result /= Void
		end

	confirm_box (a_message: STRING): SV_MESSAGE_BOX
			-- Create OK/Cancel confirmation dialog.
		require
			message_not_empty: not a_message.is_empty
		do
			create Result.make_confirm (a_message)
		ensure
			result_attached: Result /= Void
		end

	color_picker: SV_COLOR_PICKER
			-- Create color picker dialog.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	color_picker_with (a_red, a_green, a_blue: INTEGER): SV_COLOR_PICKER
			-- Create color picker with initial color.
		require
			valid_red: a_red >= 0 and a_red <= 255
			valid_green: a_green >= 0 and a_green <= 255
			valid_blue: a_blue >= 0 and a_blue <= 255
		local
			l_color: EV_COLOR
		do
			create l_color.make_with_8_bit_rgb (a_red, a_green, a_blue)
			create Result.make_with_color (l_color)
		ensure
			result_attached: Result /= Void
		end

	font_picker: SV_FONT_PICKER
			-- Create font picker dialog.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

feature -- Phase 2 Additions

	password_field: SV_PASSWORD_FIELD
			-- Create empty password field.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	password: SV_PASSWORD_FIELD
			-- Create empty password field (alias).
		do
			Result := password_field
		ensure
			result_attached: Result /= Void
		end

	secure_input: SV_PASSWORD_FIELD
			-- Create empty password field (SwiftUI-style alias).
		do
			Result := password_field
		ensure
			result_attached: Result /= Void
		end

feature -- Phase 3 Additions (Layouts)

	grid: SV_GRID
			-- Create empty grid layout.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	grid_sized (a_columns, a_rows: INTEGER): SV_GRID
			-- Create grid with specified dimensions.
		require
			valid_columns: a_columns > 0
			valid_rows: a_rows > 0
		do
			create Result.make_sized (a_columns, a_rows)
		ensure
			result_attached: Result /= Void
		end

	stack: SV_STACK
			-- Create empty stack (absolute positioning).
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	card: SV_CARD
			-- Create empty card/panel.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	card_titled (a_title: READABLE_STRING_GENERAL): SV_CARD
			-- Create card with title.
		require
			title_not_void: a_title /= Void
		do
			create Result.make_with_title (a_title)
		ensure
			result_attached: Result /= Void
		end

	panel: SV_CARD
			-- Create empty panel (alias for card).
		do
			Result := card
		ensure
			result_attached: Result /= Void
		end

	scroll: SV_SCROLL
			-- Create scrollable container.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	scroll_area: SV_SCROLL
			-- Create scrollable container (alias).
		do
			Result := scroll
		ensure
			result_attached: Result /= Void
		end

	spacer: SV_SPACER
			-- Create flexible spacer.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	spacer_fixed (a_size: INTEGER): SV_SPACER
			-- Create fixed-size spacer.
		require
			positive_size: a_size > 0
		do
			create Result.make_fixed (a_size)
		ensure
			result_attached: Result /= Void
		end

	separator_horizontal: SV_SEPARATOR
			-- Create horizontal separator line.
		do
			create Result.make_horizontal
		ensure
			result_attached: Result /= Void
		end

	separator_vertical: SV_SEPARATOR
			-- Create vertical separator line.
		do
			create Result.make_vertical
		ensure
			result_attached: Result /= Void
		end

	divider: SV_DIVIDER
			-- Create themed horizontal divider line.
		do
			create Result.make_horizontal
		ensure
			result_attached: Result /= Void
		end

	divider_vertical: SV_DIVIDER
			-- Create themed vertical divider line.
		do
			create Result.make_vertical
		ensure
			result_attached: Result /= Void
		end

feature -- Phase 4 Additions (Data)

	data_grid: SV_DATA_GRID
			-- Create empty data grid.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	data_grid_with (a_columns: ARRAY [STRING]): SV_DATA_GRID
			-- Create data grid with columns.
		require
			columns_attached: a_columns /= Void
		do
			create Result.make_with_columns (a_columns)
		ensure
			result_attached: Result /= Void
		end

	table: SV_DATA_GRID
			-- Create empty data grid (alias).
		do
			Result := data_grid
		ensure
			result_attached: Result /= Void
		end

	decimal_field: SV_DECIMAL_FIELD
			-- Create empty decimal input field.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	decimal_field_with (a_value: SIMPLE_DECIMAL): SV_DECIMAL_FIELD
			-- Create decimal field with initial value.
		require
			value_attached: a_value /= Void
		do
			create Result.make_with_value (a_value)
		ensure
			result_attached: Result /= Void
		end

	currency_field: SV_DECIMAL_FIELD
			-- Create currency input field (2 decimal places, positive only).
		do
			create Result.make
			Result := Result.cents.positive_only
		ensure
			result_attached: Result /= Void
		end

feature -- Masked Fields (Phase 6.75)

	masked_field: SV_MASKED_FIELD
			-- Create empty masked field (set mask with .mask_* methods).
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	masked_field_with (a_pattern: READABLE_STRING_GENERAL): SV_MASKED_FIELD
			-- Create masked field with custom regex pattern.
		require
			pattern_attached: a_pattern /= Void
		do
			create Result.make_with_mask (a_pattern)
		ensure
			result_attached: Result /= Void
		end

	phone_field: SV_MASKED_FIELD
			-- Create US phone number field.
		do
			create Result.make
			Result := Result.mask_phone_us.placeholder ("(123) 456-7890")
		ensure
			result_attached: Result /= Void
		end

	ssn_field: SV_MASKED_FIELD
			-- Create Social Security Number field.
		do
			create Result.make
			Result := Result.mask_ssn.placeholder ("123-45-6789")
		ensure
			result_attached: Result /= Void
		end

	date_field: SV_MASKED_FIELD
			-- Create US date field (MM/DD/YYYY).
		do
			create Result.make
			Result := Result.mask_date_us.placeholder ("MM/DD/YYYY")
		ensure
			result_attached: Result /= Void
		end

	date_field_iso: SV_MASKED_FIELD
			-- Create ISO date field (YYYY-MM-DD).
		do
			create Result.make
			Result := Result.mask_date_iso.placeholder ("YYYY-MM-DD")
		ensure
			result_attached: Result /= Void
		end

	email_field: SV_MASKED_FIELD
			-- Create email address field.
		do
			create Result.make
			Result := Result.mask_email.placeholder ("user@example.com")
		ensure
			result_attached: Result /= Void
		end

	zip_code_field: SV_MASKED_FIELD
			-- Create US ZIP code field.
		do
			create Result.make
			Result := Result.mask_zip_us.placeholder ("12345")
		ensure
			result_attached: Result /= Void
		end

	credit_card_field: SV_MASKED_FIELD
			-- Create credit card number field.
		do
			create Result.make
			Result := Result.mask_credit_card.placeholder ("1234 5678 9012 3456")
		ensure
			result_attached: Result /= Void
		end

	ip_address_field: SV_MASKED_FIELD
			-- Create IPv4 address field.
		do
			create Result.make
			Result := Result.mask_ipv4.placeholder ("192.168.1.1")
		ensure
			result_attached: Result /= Void
		end

	time_field: SV_MASKED_FIELD
			-- Create 24-hour time field (HH:MM).
		do
			create Result.make
			Result := Result.mask_time_24h.placeholder ("HH:MM")
		ensure
			result_attached: Result /= Void
		end

feature -- Phase 5 Additions

	image: SV_IMAGE
			-- Create empty image widget.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	image_from (a_path: READABLE_STRING_GENERAL): SV_IMAGE
			-- Create image from file.
		require
			path_not_empty: not a_path.is_empty
		do
			create Result.make_from_file (a_path)
		ensure
			result_attached: Result /= Void
		end

	image_sized (a_width, a_height: INTEGER): SV_IMAGE
			-- Create blank image of specified size.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			create Result.make_sized (a_width, a_height)
		ensure
			result_attached: Result /= Void
		end

feature -- Theming

	color_from_hex (a_hex: STRING): SV_COLOR
			-- Create color from hex string.
		require
			hex_valid: a_hex /= Void and then not a_hex.is_empty
		do
			create Result.make_from_hex (a_hex)
		end

	color_rgb (r, g, b: INTEGER): SV_COLOR
			-- Create color from RGB values.
		require
			valid_r: r >= 0 and r <= 255
			valid_g: g >= 0 and g <= 255
			valid_b: b >= 0 and b <= 255
		do
			create Result.make_rgb (r, g, b)
		end

	set_dark_mode (a_dark: BOOLEAN)
			-- Set dark mode on/off.
		do
			theme.set_dark_mode (a_dark)
		end

	toggle_dark_mode
			-- Toggle dark mode.
		do
			theme.toggle_dark_mode
		end

	set_theme_mode (a_mode: INTEGER)
			-- Set theme mode (Mode_light, Mode_dark, Mode_system).
		do
			theme.set_theme_mode (a_mode)
		end

	set_color_scheme (a_scheme: STRING)
			-- Set color scheme by name.
		require
			scheme_valid: a_scheme /= Void and then not a_scheme.is_empty
		do
			theme.set_color_scheme (a_scheme)
		end

	increase_ui_scale
			-- Increase UI scale (zoom in).
		do
			theme.increase_scale
		end

	decrease_ui_scale
			-- Decrease UI scale (zoom out).
		do
			theme.decrease_scale
		end

	set_ui_scale (a_scale: REAL)
			-- Set UI scale (0.5 to 3.0).
		require
			valid_scale: a_scale >= 0.5 and a_scale <= 3.0
		do
			theme.set_ui_scale (a_scale)
		end

	reset_ui_scale
			-- Reset UI scale to 100%.
		do
			theme.reset_scale
		end

feature -- Forms (Phase 6.75)

	form: SV_FORM
			-- Create empty form.
		do
			create Result.make
		ensure
			result_attached: Result /= Void
		end

	field (a_name: STRING): SV_FIELD
			-- Create form field with name.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make (a_name)
		ensure
			result_attached: Result /= Void
		end

	form_field (a_name: STRING): SV_FIELD
			-- Create form field with name (alias).
		require
			name_not_empty: not a_name.is_empty
		do
			Result := field (a_name)
		ensure
			result_attached: Result /= Void
		end

end
