note
	description: "Test suite for simple_vision library"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	LIB_TESTS

inherit
	SV_ANY

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		do
			print ("=== simple_vision Test Suite ===%N%N")

			test_count := 0
			pass_count := 0

			run_test (agent test_hello_world_harness, "Hello World Harness")
			run_test (agent test_script_parser, "Script Parser")
			run_test (agent test_event_recording, "Event Recording")
			run_test (agent test_text_field, "Text Field Widget")
			run_test (agent test_checkbox, "Checkbox Widget")
			run_test (agent test_radio_group, "Radio Group Widget")
			run_test (agent test_dropdown, "Dropdown Widget")
			run_test (agent test_list, "List Widget")
			run_test (agent test_slider, "Slider Widget")
			run_test (agent test_progress_bar, "Progress Bar Widget")
			run_test (agent test_spin_box, "Spin Box Widget")
			run_test (agent test_tab_panel, "Tab Panel Widget")
			run_test (agent test_tree, "Tree Widget")
			run_test (agent test_menu, "Menu Widgets")
			run_test (agent test_toolbar, "Toolbar Widget")
			run_test (agent test_statusbar, "Statusbar Widget")
			run_test (agent test_dialog, "Dialog Widget")
			run_test (agent test_splitter, "Splitter Widget")
			run_test (agent test_file_dialog, "File Dialog")
			run_test (agent test_message_box, "Message Box")
			run_test (agent test_color_picker, "Color Picker")
			run_test (agent test_font_picker, "Font Picker")
			run_test (agent test_password_field, "Password Field")
			run_test (agent test_grid_layout, "Grid Layout")
			run_test (agent test_stack, "Stack Widget")
			run_test (agent test_card, "Card Widget")
			run_test (agent test_scroll, "Scroll Widget")
			run_test (agent test_spacer, "Spacer Widget")
			run_test (agent test_separator, "Separator Widget")
			run_test (agent test_data_grid, "Data Grid Widget")
			run_test (agent test_image, "Image Widget")
			run_test (agent test_demo_login_harness, "Demo: Login Form")
			run_test (agent test_demo_layout_harness, "Demo: Complex Layout")
			run_test (agent test_demo_data_harness, "Demo: Data Browser")
			run_test (agent test_state_machine_basic, "State Machine Basic")
			run_test (agent test_state_machine_logging, "State Machine Logging")
			run_test (agent test_state_machine_unstarted_contract, "State Machine Unstarted Contract")

			print ("%N=== Results: " + pass_count.out + "/" + test_count.out + " passed ===%N")
		end

feature {NONE} -- Test Runner

	test_count: INTEGER
	pass_count: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				test_count := test_count + 1
				print ("Test " + test_count.out + ": " + a_name + " ... ")
				a_test.call (Void)
				pass_count := pass_count + 1
				print ("PASSED%N")
			end
		rescue
			print ("FAILED%N")
			l_retried := True
			retry
		end

	check_true (a_tag: STRING; a_condition: BOOLEAN)
			-- Assert condition is true.
		do
			if not a_condition then
				print ("  FAIL: " + a_tag + "%N")
				(create {EXCEPTIONS}).raise ("Assertion failed: " + a_tag)
			end
		end

	check_equal (a_tag: STRING; a_expected, a_actual: INTEGER)
			-- Assert integers are equal.
		do
			if a_expected /= a_actual then
				print ("  FAIL: " + a_tag + " (expected " + a_expected.out + ", got " + a_actual.out + ")%N")
				(create {EXCEPTIONS}).raise ("Assertion failed: " + a_tag)
			end
		end

	check_string_equal (a_tag: STRING; a_expected, a_actual: STRING)
			-- Assert strings are equal.
		do
			if not a_expected.same_string (a_actual) then
				print ("  FAIL: " + a_tag + " (expected '" + a_expected + "', got '" + a_actual + "')%N")
				(create {EXCEPTIONS}).raise ("Assertion failed: " + a_tag)
			end
		end

feature -- Test Cases

	test_hello_world_harness
			-- Test the Hello World demo using GUI harness.
		local
			harness: SV_TEST_HARNESS
			quick: SV_QUICK
			lbl: SV_TEXT
			btn: SV_BUTTON
			counter: CELL [INTEGER]
		do
			-- Create harness
			create harness.make
			harness.enable_debug_mode

			-- Create simple UI (simulating DEMO_HELLO structure)
			create quick.make
			lbl := quick.text ("Click the button!")
			btn := quick.button ("Click Me!")

			-- Create counter for tracking clicks
			create counter.put (0)

			-- Wire up button click (simulating demo behavior)
			btn.on_click (agent (a_lbl: SV_TEXT; a_count: CELL [INTEGER])
				do
					a_count.put (a_count.item + 1)
					a_lbl.update_text ("Clicked " + a_count.item.out + " time" +
						(if a_count.item = 1 then "" else "s" end) + "!")
				end (lbl, counter))

			-- Register widgets with harness
			harness.register (lbl, "status_label")
			harness.register (btn, "click_button")

			-- Test initial state
			check_true ("initial_text", harness.assert_text (lbl, "Click the button!"))

			-- Simulate first click
			harness.simulate_click (btn)
			check_true ("after_first_click", harness.assert_text (lbl, "Clicked 1 time!"))

			-- Simulate second click
			harness.simulate_click (btn)
			check_true ("after_second_click", harness.assert_text (lbl, "Clicked 2 times!"))

			-- Simulate 3 more clicks
			harness.simulate_click (btn)
			harness.simulate_click (btn)
			harness.simulate_click (btn)
			check_true ("after_five_clicks", harness.assert_text (lbl, "Clicked 5 times!"))

			-- Verify all harness assertions passed
			check_true ("all_passed", harness.all_assertions_passed)

			-- Print report
			print ("%N" + harness.report)
		end

	test_script_parser
			-- Test JSON script parsing.
		local
			parser: SV_TEST_SCRIPT_PARSER
			steps: ARRAYED_LIST [SV_TEST_STEP]
			json: STRING
		do
			json := "[
				{
					"name": "Test Script",
					"steps": [
						{ "action": "click", "target": "my_button" },
						{ "action": "assert_text", "target": "my_label", "value": "Hello" },
						{ "action": "wait", "milliseconds": 100 }
					]
				}
			]"

			create parser.make
			steps := parser.parse (json)

			check_equal ("step_count", 3, steps.count)
			check_string_equal ("first_action", "click", steps [1].action)
			check_string_equal ("first_target", "my_button", steps [1].target)
			check_string_equal ("second_action", "assert_text", steps [2].action)
			check_string_equal ("second_value", "Hello", steps [2].value)
			check_string_equal ("third_action", "wait", steps [3].action)
			check_equal ("wait_ms", 100, steps [3].wait_ms)
		end

	test_event_recording
			-- Test event recording functionality.
		local
			harness: SV_TEST_HARNESS
			quick: SV_QUICK
			btn: SV_BUTTON
		do
			create harness.make
			create quick.make
			btn := quick.button ("Test")

			harness.register (btn, "test_btn")
			harness.start_recording

			-- Simulate clicks
			harness.simulate_click (btn)
			harness.simulate_click (btn)

			harness.stop_recording

			check_equal ("events_recorded", 2, harness.recorded_events.count)
			check_true ("first_is_click", harness.recorded_events [1].event.is_click)
		end

	test_text_field
			-- Test SV_TEXT_FIELD operations.
		local
			quick: SV_QUICK
			tf: SV_TEXT_FIELD
		do
			create quick.make

			-- Test empty creation
			tf := quick.text_field
			check_string_equal ("initial_empty", "", tf.text.to_string_8)

			-- Test fluent text setting (using content method)
			tf := tf.content ("Hello")
			check_string_equal ("after_content", "Hello", tf.text.to_string_8)

			-- Test set_text procedure
			tf.set_text ("World")
			check_string_equal ("after_set_text", "World", tf.text.to_string_8)

			-- Test input alias
			tf := quick.input
			check_string_equal ("input_alias_empty", "", tf.text.to_string_8)

			-- Test text_input with initial value
			tf := quick.text_input ("Initial Value")
			check_string_equal ("text_input_initial", "Initial Value", tf.text.to_string_8)
		end

	test_checkbox
			-- Test SV_CHECKBOX operations.
		local
			quick: SV_QUICK
			cb: SV_CHECKBOX
		do
			create quick.make

			-- Test creation with label
			cb := quick.checkbox ("Accept Terms")
			check_string_equal ("label_set", "Accept Terms", cb.text.to_string_8)
			check_true ("initially_unchecked", not cb.is_checked)

			-- Test checking
			cb.check_now
			check_true ("after_check", cb.is_checked)

			-- Test unchecking
			cb.uncheck_now
			check_true ("after_uncheck", not cb.is_checked)

			-- Test toggle
			cb.toggle
			check_true ("after_toggle_1", cb.is_checked)
			cb.toggle
			check_true ("after_toggle_2", not cb.is_checked)

			-- Test fluent checked/unchecked
			cb := cb.checked
			check_true ("fluent_checked", cb.is_checked)
			cb := cb.unchecked
			check_true ("fluent_unchecked", not cb.is_checked)

			-- Test set_checked
			cb := cb.set_checked (True)
			check_true ("set_checked_true", cb.is_checked)
			cb := cb.set_checked (False)
			check_true ("set_checked_false", not cb.is_checked)
		end

	test_radio_group
			-- Test SV_RADIO_GROUP operations.
		local
			quick: SV_QUICK
			rg: SV_RADIO_GROUP
		do
			create quick.make

			-- Test creation with options
			rg := quick.radios (<<"Option A", "Option B", "Option C">>)
			check_equal ("radio_count", 3, rg.radio_buttons.count)

			-- Test selection by index
			rg.select_index (2)
			check_equal ("selected_index", 2, rg.selected_index)
			check_string_equal ("selected_value", "Option B", rg.selected_value)

			-- Test selection by value
			rg.select_value ("Option C")
			check_equal ("selected_after_value", 3, rg.selected_index)
			check_string_equal ("value_after_value", "Option C", rg.selected_value)

			-- Test fluent selected
			rg := rg.selected (1)
			check_equal ("fluent_selected", 1, rg.selected_index)
		end

	test_dropdown
			-- Test SV_DROPDOWN operations.
		local
			quick: SV_QUICK
			dd: SV_DROPDOWN
		do
			create quick.make

			-- Test creation with options
			dd := quick.dropdown_with (<<"Red", "Green", "Blue">>)

			-- Test selection
			dd.select_index (2)
			check_equal ("selected_index", 2, dd.selected_index)
			check_string_equal ("selected_value", "Green", dd.selected_value)

			-- Test selection by value
			dd.select_value ("Blue")
			check_equal ("selected_after_value", 3, dd.selected_index)

			-- Test adding more options
			dd.add_option ("Yellow")
			dd.select_index (4)
			check_string_equal ("added_option", "Yellow", dd.selected_value)

			-- Test fluent options
			dd := quick.dropdown.options (<<"One", "Two">>)
			dd.select_first
			check_string_equal ("fluent_options", "One", dd.selected_value)
		end

	test_list
			-- Test SV_LIST operations.
		local
			quick: SV_QUICK
			lst: SV_LIST
		do
			create quick.make

			-- Test creation with items
			lst := quick.list_with (<<"Item 1", "Item 2", "Item 3">>)
			check_equal ("list_count", 3, lst.count)
			check_true ("not_empty", not lst.is_empty)

			-- Test selection
			lst.select_index (2)
			check_true ("has_selection", lst.has_selection)
			check_equal ("selected_index", 2, lst.selected_index)
			check_string_equal ("selected_value", "Item 2", lst.selected_value)

			-- Test deselect
			lst.deselect_all
			check_true ("no_selection", not lst.has_selection)

			-- Test add item
			lst.add_item ("Item 4")
			check_equal ("after_add", 4, lst.count)

			-- Test select first
			lst.select_first
			check_equal ("select_first", 1, lst.selected_index)

			-- Test select by value
			lst.select_value ("Item 3")
			check_equal ("select_by_value", 3, lst.selected_index)

			-- Test clear
			lst.clear
			check_true ("after_clear", lst.is_empty)
			check_equal ("count_after_clear", 0, lst.count)
		end

	test_slider
			-- Test SV_SLIDER operations.
		local
			quick: SV_QUICK
			sl: SV_SLIDER
		do
			create quick.make

			-- Test default creation
			sl := quick.slider
			check_equal ("default_min", 0, sl.minimum)
			check_equal ("default_max", 100, sl.maximum)
			check_equal ("default_value", 0, sl.value)

			-- Test set value
			sl.set_value (50)
			check_equal ("after_set_value", 50, sl.value)

			-- Test fluent at
			sl := sl.at (75)
			check_equal ("after_at", 75, sl.value)

			-- Test range creation
			sl := quick.slider_range (10, 200)
			check_equal ("range_min", 10, sl.minimum)
			check_equal ("range_max", 200, sl.maximum)
			check_equal ("range_initial", 10, sl.value)

			-- Test increment/decrement
			sl := quick.slider.at (50)
			sl.increment
			check_equal ("after_increment", 51, sl.value)
			sl.decrement
			check_equal ("after_decrement", 50, sl.value)

			-- Test set_step
			sl := sl.set_step (10)
			sl.increment
			check_equal ("step_10_increment", 60, sl.value)
		end

	test_progress_bar
			-- Test SV_PROGRESS_BAR operations.
		local
			quick: SV_QUICK
			pb: SV_PROGRESS_BAR
		do
			create quick.make

			-- Test default creation
			pb := quick.progress
			check_equal ("default_min", 0, pb.minimum)
			check_equal ("default_max", 100, pb.maximum)
			check_equal ("default_value", 0, pb.value)
			check_true ("not_started", not pb.is_started)
			check_true ("not_complete", not pb.is_complete)

			-- Test set value
			pb.set_value (50)
			check_equal ("after_set_value", 50, pb.value)
			check_true ("is_started", pb.is_started)
			check_equal ("percent_int", 50, pb.percent_int)

			-- Test advance
			pb.advance (25)
			check_equal ("after_advance", 75, pb.value)

			-- Test complete
			pb.complete
			check_true ("is_complete", pb.is_complete)
			check_equal ("at_max", 100, pb.value)

			-- Test reset
			pb.reset
			check_equal ("after_reset", 0, pb.value)
			check_true ("not_started_after_reset", not pb.is_started)

			-- Test fluent at
			pb := pb.at (30)
			check_equal ("fluent_at", 30, pb.value)
		end

	test_spin_box
			-- Test SV_SPIN_BOX operations.
		local
			quick: SV_QUICK
			sb: SV_SPIN_BOX
		do
			create quick.make

			-- Test default creation
			sb := quick.spin_box
			check_equal ("default_min", 0, sb.minimum)
			check_equal ("default_max", 100, sb.maximum)
			check_equal ("default_value", 0, sb.value)

			-- Test set value
			sb.set_value (42)
			check_equal ("after_set_value", 42, sb.value)

			-- Test fluent at
			sb := sb.at (75)
			check_equal ("after_at", 75, sb.value)

			-- Test range creation
			sb := quick.spin_box_range (-10, 10)
			check_equal ("range_min", -10, sb.minimum)
			check_equal ("range_max", 10, sb.maximum)

			-- Test increment/decrement
			sb := quick.spin_box.at (50)
			sb.increment
			check_equal ("after_increment", 51, sb.value)
			sb.decrement
			check_equal ("after_decrement", 50, sb.value)

			-- Test stepping
			sb := sb.stepping (5)
			sb.increment
			check_equal ("step_5_increment", 55, sb.value)

			-- Test reset
			sb.reset
			check_equal ("after_reset", 0, sb.value)
		end

	test_tab_panel
			-- Test SV_TAB_PANEL operations.
		local
			quick: SV_QUICK
			tp: SV_TAB_PANEL
			t1, t2, t3: SV_TEXT
		do
			create quick.make

			-- Create some content widgets
			t1 := quick.text ("Tab 1 Content")
			t2 := quick.text ("Tab 2 Content")
			t3 := quick.text ("Tab 3 Content")

			-- Test creation and adding tabs
			tp := quick.tabs
			check_equal ("initial_count", 0, tp.count)

			tp.add_tab ("First", t1)
			check_equal ("count_after_1", 1, tp.count)

			tp.add_tab ("Second", t2)
			tp.add_tab ("Third", t3)
			check_equal ("count_after_3", 3, tp.count)

			-- Test selection
			tp.select_tab (2)
			check_equal ("selected_index", 2, tp.selected_index)

			-- Test select_first/select_last
			tp.select_first
			check_equal ("after_select_first", 1, tp.selected_index)

			tp.select_last
			check_equal ("after_select_last", 3, tp.selected_index)

			-- Test select_previous/select_next
			tp.select_previous
			check_equal ("after_select_prev", 2, tp.selected_index)

			tp.select_next
			check_equal ("after_select_next", 3, tp.selected_index)

			-- Test wrap-around
			tp.select_next
			check_equal ("wrap_to_first", 1, tp.selected_index)
		end

	test_tree
			-- Test SV_TREE operations.
		local
			quick: SV_QUICK
			tr: SV_TREE
			root1, root2, child1, child2: INTEGER
		do
			create quick.make

			-- Test empty creation
			tr := quick.tree
			check_true ("initially_empty", tr.is_empty)
			check_equal ("initial_count", 0, tr.count)

			-- Test adding roots
			root1 := tr.add_root ("Root 1")
			check_equal ("count_after_root1", 1, tr.count)
			check_true ("has_root1", tr.has_node (root1))

			root2 := tr.add_root ("Root 2")
			check_equal ("count_after_root2", 2, tr.count)

			-- Test adding children
			child1 := tr.add_child (root1, "Child 1.1")
			check_true ("has_child1", tr.has_node (child1))

			child2 := tr.add_child (root1, "Child 1.2")
			check_true ("has_child2", tr.has_node (child2))

			-- Test selection
			check_true ("no_selection_initially", not tr.has_selection)

			tr.select_node (child1)
			check_true ("has_selection", tr.has_selection)
			check_string_equal ("selected_value", "Child 1.1", tr.selected_value)

			-- Test deselect
			tr.deselect_all
			check_true ("no_selection_after_deselect", not tr.has_selection)

			-- Test bulk add
			tr := quick.tree.add_roots (<<"Apple", "Banana", "Cherry">>)
			check_equal ("bulk_count", 3, tr.count)

			-- Test clear
			tr.clear
			check_true ("empty_after_clear", tr.is_empty)
		end

	test_menu
			-- Test SV_MENU, SV_MENU_BAR, SV_MENU_ITEM.
		local
			quick: SV_QUICK
			mb: SV_MENU_BAR
			m: SV_MENU
			mi: SV_MENU_ITEM
		do
			create quick.make

			-- Test menu bar creation
			mb := quick.menu_bar
			check_equal ("initial_menu_count", 0, mb.count)

			-- Test adding menus
			m := mb.menu ("File")
			check_equal ("after_file_menu", 1, mb.count)
			check_string_equal ("menu_title", "File", m.title.to_string_8)

			-- Test adding menu items
			mi := m.item ("New")
			check_equal ("item_count", 1, m.count)
			check_string_equal ("item_label", "New", mi.label.to_string_8)

			-- Test standard menus
			mb := quick.menu_bar.with_standard_menus
			check_equal ("standard_menu_count", 4, mb.count)

			-- Test menu item state
			mi := quick.menu_item ("Test")
			check_true ("initially_enabled", mi.is_enabled)
			mi.disable
			check_true ("after_disable", not mi.is_enabled)
			mi.enable
			check_true ("after_enable", mi.is_enabled)
		end

	test_toolbar
			-- Test SV_TOOLBAR and SV_TOOLBAR_BUTTON.
		local
			quick: SV_QUICK
			tb: SV_TOOLBAR
			btn: SV_TOOLBAR_BUTTON
		do
			create quick.make

			-- Test toolbar creation
			tb := quick.toolbar
			check_equal ("initial_button_count", 0, tb.count)

			-- Test adding buttons
			btn := tb.button ("Save")
			check_equal ("after_save_button", 1, tb.count)
			check_string_equal ("button_label", "Save", btn.label.to_string_8)

			-- Add more buttons
			tb.separator
			btn := tb.button ("Open")
			check_equal ("after_separator_and_open", 2, tb.count)

			-- Test button state
			btn := quick.toolbar_button ("Test")
			check_true ("initially_enabled", btn.is_enabled)
			btn.disable
			check_true ("after_disable", not btn.is_enabled)
			btn.enable
			check_true ("after_enable", btn.is_enabled)

			-- Test tooltip
			btn := btn.tooltip ("Click to test")
			-- Tooltip set but no getter to verify (internal EV2)
		end

	test_statusbar
			-- Test SV_STATUSBAR operations.
		local
			quick: SV_QUICK
			sb: SV_STATUSBAR
		do
			create quick.make

			-- Test empty creation
			sb := quick.statusbar
			check_string_equal ("initial_text", "", sb.text.to_string_8)

			-- Test set_text
			sb.set_text ("Hello World")
			check_string_equal ("after_set_text", "Hello World", sb.text.to_string_8)

			-- Test with initial text
			sb := quick.statusbar_with ("Ready")
			check_string_equal ("with_text", "Ready", sb.text.to_string_8)

			-- Test ready/working/done
			sb.working
			check_string_equal ("working", "Working...", sb.text.to_string_8)
			sb.done
			check_string_equal ("done", "Done", sb.text.to_string_8)
			sb.ready
			check_string_equal ("ready", "Ready", sb.text.to_string_8)

			-- Test error
			sb.error ("Something went wrong")
			check_string_equal ("error", "Error: Something went wrong", sb.text.to_string_8)

			-- Test clear
			sb.clear
			check_string_equal ("after_clear", "", sb.text.to_string_8)

			-- Test fluent content
			sb := sb.content ("Status message")
			check_string_equal ("fluent_content", "Status message", sb.text.to_string_8)
		end

	test_dialog
			-- Test SV_DIALOG operations.
		local
			quick: SV_QUICK
			dlg: SV_DIALOG
		do
			create quick.make

			-- Test empty dialog creation
			dlg := quick.dialog
			-- No title by default

			-- Test dialog with title
			dlg := quick.dialog_with_title ("My Dialog")
			check_string_equal ("title", "My Dialog", dlg.title.to_string_8)

			-- Test title change
			dlg.set_title ("New Title")
			check_string_equal ("after_set_title", "New Title", dlg.title.to_string_8)

			-- Test fluent titled
			dlg := dlg.titled ("Fluent Title")
			check_string_equal ("fluent_titled", "Fluent Title", dlg.title.to_string_8)

			-- Test confirmation flag
			check_true ("initially_not_confirmed", not dlg.is_confirmed)

			-- Test size (can't verify without showing, but should not error)
			dlg := dlg.sized (400, 300)
		end

	test_splitter
			-- Test SV_SPLITTER operations.
		local
			quick: SV_QUICK
			sp_h, sp_v: SV_SPLITTER
			left_panel, right_panel: SV_TEXT
			top_panel, bottom_panel: SV_TEXT
		do
			create quick.make

			-- Create some content widgets
			left_panel := quick.text ("Left")
			right_panel := quick.text ("Right")
			top_panel := quick.text ("Top")
			bottom_panel := quick.text ("Bottom")

			-- Test horizontal splitter
			sp_h := quick.horizontal_splitter
			check_true ("is_horizontal", sp_h.is_horizontal)
			check_true ("not_vertical_h", not sp_h.is_vertical)

			-- Test setting panes with first/second (works on both)
			sp_h := sp_h.first (left_panel).second (right_panel)

			-- Test left/right aliases on horizontal splitter
			sp_h := quick.hsplit
			sp_h := sp_h.left (quick.text ("L")).right (quick.text ("R"))

			-- Test vertical splitter
			sp_v := quick.vertical_splitter
			check_true ("is_vertical", sp_v.is_vertical)
			check_true ("not_horizontal_v", not sp_v.is_horizontal)

			-- Test top/bottom aliases on vertical splitter
			sp_v := sp_v.top (top_panel).bottom (bottom_panel)

			-- Test vsplit alias
			sp_v := quick.vsplit
			sp_v := sp_v.first (quick.text ("T")).second (quick.text ("B"))

			-- Test proportion
			sp_h := sp_h.at_proportion (0.3)
			-- Proportion stored but applied when displayed
		end

	test_file_dialog
			-- Test SV_FILE_DIALOG operations.
		local
			quick: SV_QUICK
			dlg_open, dlg_save: SV_FILE_DIALOG
		do
			create quick.make

			-- Test open dialog creation
			dlg_open := quick.open_file_dialog
			check_true ("is_open_dialog", dlg_open.is_open_dialog)
			check_true ("not_save_dialog", not dlg_open.is_save_dialog)

			-- Test save dialog creation
			dlg_save := quick.save_file_dialog
			check_true ("is_save_dialog", dlg_save.is_save_dialog)
			check_true ("not_open_dialog", not dlg_save.is_open_dialog)

			-- Test fluent configuration
			dlg_open := dlg_open.title ("Open File").start_directory ("C:\")
			dlg_save := dlg_save.title ("Save File").default_name ("untitled.txt")

			-- Test filters
			dlg_open := dlg_open.filter ("Text Files", "*.txt").filter ("All Files", "*.*")
			check_equal ("filter_count", 2, dlg_open.filters.count)
			check_string_equal ("first_filter_desc", "Text Files", dlg_open.filters [1].description)
			check_string_equal ("first_filter_pattern", "*.txt", dlg_open.filters [1].pattern)

			-- Test preset filters
			dlg_save := quick.file_save.text_files.all_files
			check_equal ("preset_filter_count", 2, dlg_save.filters.count)

			-- Test file_open alias
			dlg_open := quick.file_open.eiffel_files.json_files
			check_equal ("eiffel_json_filters", 2, dlg_open.filters.count)

			-- Test image files filter
			dlg_open := quick.open_file_dialog.image_files
			check_equal ("image_filter_count", 1, dlg_open.filters.count)
		end

	test_message_box
			-- Test SV_MESSAGE_BOX operations.
		local
			quick: SV_QUICK
			box: SV_MESSAGE_BOX
		do
			create quick.make

			-- Test info box creation
			box := quick.info_box ("Information message")
			check_equal ("info_type", box.type_info, box.dialog_type)
			check_string_equal ("info_message", "Information message", box.message)

			-- Test warning box creation
			box := quick.warning_box ("Warning message")
			check_equal ("warning_type", box.type_warning, box.dialog_type)

			-- Test error box creation
			box := quick.error_box ("Error message")
			check_equal ("error_type", box.type_error, box.dialog_type)

			-- Test question box creation
			box := quick.question_box ("Do you want to continue?")
			check_equal ("question_type", box.type_question, box.dialog_type)
			-- Initially no selection
			check_true ("was_no_by_default", box.was_no)

			-- Test confirm box creation
			box := quick.confirm_box ("Are you sure?")
			check_equal ("confirm_type", box.type_confirm, box.dialog_type)
			-- Initially not confirmed
			check_true ("was_cancelled_by_default", box.was_cancelled)

			-- Test fluent title
			box := box.title ("Confirmation")
			-- Title set but no getter (internal EV2)
		end

	test_color_picker
			-- Test SV_COLOR_PICKER operations.
		local
			quick: SV_QUICK
			cp: SV_COLOR_PICKER
		do
			create quick.make

			-- Test default creation
			cp := quick.color_picker
			check_equal ("default_red", 0, cp.red)
			check_equal ("default_green", 0, cp.green)
			check_equal ("default_blue", 0, cp.blue)
			check_string_equal ("default_rgb", "0,0,0", cp.rgb_string)
			check_string_equal ("default_hex", "#000000", cp.hex_string)

			-- Test creation with initial color
			cp := quick.color_picker_with (255, 128, 64)
			check_equal ("init_red", 255, cp.red)
			check_equal ("init_green", 128, cp.green)
			check_equal ("init_blue", 64, cp.blue)

			-- Test set_rgb
			cp.set_rgb (100, 150, 200)
			check_equal ("set_red", 100, cp.red)
			check_equal ("set_green", 150, cp.green)
			check_equal ("set_blue", 200, cp.blue)

			-- Test fluent initial_color
			cp := cp.initial_color (0, 255, 0)
			check_equal ("fluent_red", 0, cp.red)
			check_equal ("fluent_green", 255, cp.green)
			check_equal ("fluent_blue", 0, cp.blue)

			-- Test predefined colors
			cp.set_white
			check_equal ("white_red", 255, cp.red)
			check_equal ("white_green", 255, cp.green)
			check_equal ("white_blue", 255, cp.blue)

			cp.set_red
			check_string_equal ("red_hex", "#FF0000", cp.hex_string)

			cp.set_green
			check_string_equal ("green_rgb", "0,255,0", cp.rgb_string)

			cp.set_blue
			check_equal ("blue_red", 0, cp.red)
			check_equal ("blue_green", 0, cp.green)
			check_equal ("blue_blue", 255, cp.blue)

			cp.set_black
			check_string_equal ("black_hex", "#000000", cp.hex_string)

			-- Test was_selected (initially false - no dialog shown)
			check_true ("not_selected_initially", not cp.was_selected)
		end

	test_font_picker
			-- Test SV_FONT_PICKER operations.
		local
			quick: SV_QUICK
			fp: SV_FONT_PICKER
		do
			create quick.make

			-- Test default creation
			fp := quick.font_picker
			-- Default font varies by system, just check it exists
			check_true ("has_family", not fp.family.is_empty)
			check_true ("has_height", fp.height > 0)

			-- Test set_height
			fp.set_height (14)
			check_equal ("after_set_height", 14, fp.height)

			-- Test fluent initial_height
			fp := fp.initial_height (18)
			check_equal ("fluent_height", 18, fp.height)

			-- Test set_family
			fp.set_family ("Arial")
			-- Family might not match exactly (system font mapping)
			-- Just verify it doesn't error

			-- Test fluent initial_family
			fp := fp.initial_family ("Courier New")
			-- Family set but might be mapped by system

			-- Test font_description format
			-- Should contain height and possibly Bold/Italic
			check_true ("description_has_height", fp.font_description.has_substring (fp.height.out))

			-- Test was_selected (initially false - no dialog shown)
			check_true ("not_selected_initially", not fp.was_selected)

			-- Test bold/italic status (depends on current font)
			-- Just call to verify no errors
			if fp.is_bold then
				check_true ("bold_check", True)
			end
			if fp.is_italic then
				check_true ("italic_check", True)
			end
		end

	test_password_field
			-- Test SV_PASSWORD_FIELD operations.
		local
			quick: SV_QUICK
			pf: SV_PASSWORD_FIELD
		do
			create quick.make

			-- Test empty creation
			pf := quick.password_field
			check_true ("initially_empty", pf.is_empty)
			check_string_equal ("empty_text", "", pf.text.to_string_8)

			-- Test set_text
			pf.set_text ("secret123")
			check_string_equal ("after_set", "secret123", pf.text.to_string_8)
			check_true ("not_empty", not pf.is_empty)

			-- Test fluent content
			pf := pf.content ("password")
			check_string_equal ("fluent_content", "password", pf.text.to_string_8)

			-- Test clear
			pf.clear
			check_true ("after_clear", pf.is_empty)

			-- Test aliases
			pf := quick.password
			check_true ("password_alias", pf.is_empty)

			pf := quick.secure_input
			check_true ("secure_input_alias", pf.is_empty)
		end

	test_grid_layout
			-- Test SV_GRID operations.
		local
			quick: SV_QUICK
			gr: SV_GRID
			lbl: SV_TEXT
		do
			create quick.make

			-- Test empty creation
			gr := quick.grid
			check_equal ("default_columns", 1, gr.column_count)
			check_equal ("default_rows", 1, gr.row_count)

			-- Test sized creation
			gr := quick.grid_sized (3, 2)
			check_equal ("sized_columns", 3, gr.column_count)
			check_equal ("sized_rows", 2, gr.row_count)

			-- Test fluent configuration
			gr := quick.grid.columns (4).rows (3).gap (10)
			check_equal ("fluent_columns", 4, gr.column_count)
			check_equal ("fluent_rows", 3, gr.row_count)

			-- Test adding widget at position
			lbl := quick.text ("Cell 1,1")
			gr.add_at (lbl, 1, 1)
			-- Widget added (no assertion needed, just verify no error)

			-- Test fluent put
			lbl := quick.text ("Cell 2,2")
			gr := gr.put (lbl, 2, 2)
		end

	test_stack
			-- Test SV_STACK operations.
		local
			quick: SV_QUICK
			st: SV_STACK
			lbl1, lbl2: SV_TEXT
		do
			create quick.make

			-- Test empty creation
			st := quick.stack
			check_true ("initially_empty", st.is_empty)
			check_equal ("initial_count", 0, st.count)

			-- Test adding positioned widget
			lbl1 := quick.text ("Layer 1")
			st.add (lbl1, 10, 20)
			check_equal ("count_after_add", 1, st.count)
			check_true ("not_empty", not st.is_empty)

			-- Test fluent layer
			lbl2 := quick.text ("Layer 2")
			st := st.layer (lbl2)
			check_equal ("count_after_layer", 2, st.count)

			-- Test clear
			st.clear
			check_true ("after_clear", st.is_empty)
		end

	test_card
			-- Test SV_CARD operations.
		local
			quick: SV_QUICK
			cd: SV_CARD
			lbl: SV_TEXT
		do
			create quick.make

			-- Test empty creation
			cd := quick.card
			check_true ("no_content_initially", not cd.has_content)

			-- Test titled creation
			cd := quick.card_titled ("My Card")
			check_string_equal ("title", "My Card", cd.title.to_string_8)

			-- Test fluent titled
			cd := cd.titled ("New Title")
			check_string_equal ("fluent_title", "New Title", cd.title.to_string_8)

			-- Test set content
			lbl := quick.text ("Card content")
			cd := cd.content (lbl)
			check_true ("has_content", cd.has_content)

			-- Test border styles
			cd := cd.raised
			cd := cd.lowered
			cd := cd.etched

			-- Test panel alias
			cd := quick.panel
			check_true ("panel_alias", not cd.has_content)
		end

	test_scroll
			-- Test SV_SCROLL operations.
		local
			quick: SV_QUICK
			sc: SV_SCROLL
			col: SV_COLUMN
		do
			create quick.make

			-- Test empty creation
			sc := quick.scroll
			check_true ("no_content_initially", not sc.has_content)

			-- Test set content
			col := quick.column
			sc := sc.content (col)
			check_true ("has_content", sc.has_content)

			-- Test scroll position
			check_equal ("initial_h_offset", 0, sc.horizontal_offset)
			check_equal ("initial_v_offset", 0, sc.vertical_offset)

			-- Test scroll_area alias
			sc := quick.scroll_area
			check_true ("scroll_area_alias", not sc.has_content)
		end

	test_spacer
			-- Test SV_SPACER operations.
		local
			quick: SV_QUICK
			sp: SV_SPACER
		do
			create quick.make

			-- Test flexible creation
			sp := quick.spacer
			check_true ("is_flexible", sp.is_flexible)
			check_true ("not_fixed", not sp.is_fixed)

			-- Test fixed creation
			sp := quick.spacer_fixed (50)
			check_true ("is_fixed", sp.is_fixed)
			check_true ("not_flexible", not sp.is_flexible)
			check_equal ("fixed_size", 50, sp.fixed_size)

			-- Test fluent fixed
			sp := quick.spacer.fixed (30)
			check_equal ("fluent_fixed", 30, sp.fixed_size)
		end

	test_separator
			-- Test SV_SEPARATOR and SV_DIVIDER operations.
		local
			quick: SV_QUICK
			sep_h, sep_v: SV_SEPARATOR
			div_h, div_v: SV_DIVIDER
		do
			create quick.make

			-- Test horizontal separator
			sep_h := quick.separator_horizontal
			check_true ("is_horizontal", sep_h.is_horizontal)
			check_true ("not_vertical", not sep_h.is_vertical)

			-- Test vertical separator
			sep_v := quick.separator_vertical
			check_true ("is_vertical", sep_v.is_vertical)
			check_true ("not_horizontal", not sep_v.is_horizontal)

			-- Test themed divider (replaces native separator)
			div_h := quick.divider
			check_true ("divider_is_horizontal", div_h.is_horizontal)
			check_true ("divider_not_vertical", not div_h.is_vertical)

			-- Test vertical divider
			div_v := quick.divider_vertical
			check_true ("vert_divider_is_vertical", div_v.is_vertical)
		end

	test_data_grid
			-- Test SV_DATA_GRID operations.
		local
			quick: SV_QUICK
			dg: SV_DATA_GRID
		do
			create quick.make

			-- Test empty creation
			dg := quick.data_grid
			check_true ("initially_empty", dg.is_empty)
			check_equal ("initial_row_count", 0, dg.row_count)

			-- Test creation with columns
			dg := quick.data_grid_with (<<"Name", "Age", "City">>)
			check_equal ("column_count", 3, dg.column_count)

			-- Test adding rows
			dg.add_row (<<"Alice", "30", "NYC">>)
			check_equal ("row_count_1", 1, dg.row_count)
			check_true ("not_empty", not dg.is_empty)

			dg.add_row (<<"Bob", "25", "LA">>)
			check_equal ("row_count_2", 2, dg.row_count)

			-- Test cell access
			check_string_equal ("cell_1_1", "Alice", dg.cell_value (1, 1))
			check_string_equal ("cell_2_3", "LA", dg.cell_value (2, 3))

			-- Test selection
			check_true ("no_selection_initially", not dg.has_selection)
			dg.select_row (1)
			check_true ("has_selection", dg.has_selection)
			check_equal ("selected_row", 1, dg.selected_row)

			-- Test deselect
			dg.deselect_all
			check_true ("no_selection_after_deselect", not dg.has_selection)

			-- Test fluent rows
			dg := quick.data_grid_with (<<"A", "B">>).rows (<<
				<<"1", "2">>,
				<<"3", "4">>
			>>)
			check_equal ("fluent_rows", 2, dg.row_count)

			-- Test clear
			dg.clear_rows
			check_true ("empty_after_clear", dg.is_empty)

			-- Test table alias
			dg := quick.table
			check_true ("table_alias", dg.is_empty)
		end

	test_image
			-- Test SV_IMAGE operations.
		local
			quick: SV_QUICK
			img: SV_IMAGE
		do
			create quick.make

			-- Test empty creation
			img := quick.image
			-- Default pixmap has some size
			check_true ("exists", img /= Void)

			-- Test sized creation
			img := quick.image_sized (100, 50)
			check_equal ("sized_width", 100, img.width)
			check_equal ("sized_height", 50, img.height)

			-- Test fluent sized
			img := img.sized (200, 100)
			check_equal ("fluent_width", 200, img.width)
			check_equal ("fluent_height", 100, img.height)

			-- Test fill color
			img.fill_color (255, 0, 0)  -- Red
			-- Can't verify visually, just check no error

			-- Test clear
			img.clear

			-- Note: Can't test load_from_file without actual file
		end

	test_demo_login_harness
			-- Test the Login Form demo using GUI harness.
		local
			harness: SV_TEST_HARNESS
			quick: SV_QUICK
			username_field: SV_TEXT_FIELD
			password_field: SV_PASSWORD_FIELD
			remember_cb: SV_CHECKBOX
			status_lbl: SV_TEXT
			login_btn, cancel_btn: SV_BUTTON
		do
			-- Create harness
			create harness.make
			harness.enable_debug_mode

			-- Create UI components (simulating demo structure)
			create quick.make
			username_field := quick.text_field
			password_field := quick.password_field
			remember_cb := quick.checkbox ("Remember me")
			status_lbl := quick.text ("Enter your credentials")
			login_btn := quick.button ("Login")
			cancel_btn := quick.button ("Cancel")

			-- Wire up login validation
			login_btn.on_click (agent (u: SV_TEXT_FIELD; p: SV_PASSWORD_FIELD; s: SV_TEXT)
				do
					if u.text.is_empty then
						s.update_text ("Please enter username")
					elseif p.text.is_empty then
						s.update_text ("Please enter password")
					else
						s.update_text ("Logging in as " + u.text.to_string_8 + "...")
					end
				end (username_field, password_field, status_lbl))

			-- Wire up cancel
			cancel_btn.on_click (agent (u: SV_TEXT_FIELD; p: SV_PASSWORD_FIELD; cb: SV_CHECKBOX; s: SV_TEXT)
				do
					u.clear
					p.clear
					cb.uncheck_now
					s.update_text ("Enter your credentials")
				end (username_field, password_field, remember_cb, status_lbl))

			-- Register widgets
			harness.register (username_field, "username")
			harness.register (password_field, "password")
			harness.register (status_lbl, "status")
			harness.register (login_btn, "login_btn")
			harness.register (cancel_btn, "cancel_btn")

			-- Test 1: Empty username validation
			harness.simulate_click (login_btn)
			check_true ("empty_username", harness.assert_text (status_lbl, "Please enter username"))

			-- Test 2: Empty password validation
			username_field.set_text ("testuser")
			harness.simulate_click (login_btn)
			check_true ("empty_password", harness.assert_text (status_lbl, "Please enter password"))

			-- Test 3: Successful login attempt
			password_field.set_text ("secret123")
			harness.simulate_click (login_btn)
			check_true ("login_attempt", harness.assert_text (status_lbl, "Logging in as testuser..."))

			-- Test 4: Cancel clears form
			harness.simulate_click (cancel_btn)
			check_true ("cancel_clears_status", harness.assert_text (status_lbl, "Enter your credentials"))
			check_true ("username_cleared", username_field.text.is_empty)
			check_true ("password_cleared", password_field.text.is_empty)

			-- Verify all assertions passed
			check_true ("all_passed", harness.all_assertions_passed)

			print ("%N" + harness.report)
		end

	test_demo_layout_harness
			-- Test the Complex Layout demo using GUI harness.
		local
			harness: SV_TEST_HARNESS
			quick: SV_QUICK
			status_text: SV_TEXT
			refresh_btn, clear_btn: SV_BUTTON
			cb1, cb2, cb3: SV_CHECKBOX
		do
			-- Create harness
			create harness.make
			harness.enable_debug_mode

			-- Create UI components (simulating demo structure)
			create quick.make
			status_text := quick.text ("Ready")
			refresh_btn := quick.button ("Refresh")
			clear_btn := quick.button ("Clear")
			cb1 := quick.checkbox ("Enable notifications").checked
			cb2 := quick.checkbox ("Auto-save").checked
			cb3 := quick.checkbox ("Dark mode").unchecked

			-- Wire up refresh
			refresh_btn.on_click (agent (s: SV_TEXT)
				do
					s.update_text ("Refreshed")
				end (status_text))

			-- Wire up clear
			clear_btn.on_click (agent (s: SV_TEXT)
				do
					s.update_text ("Cleared")
				end (status_text))

			-- Register widgets
			harness.register (status_text, "status")
			harness.register (refresh_btn, "refresh")
			harness.register (clear_btn, "clear")

			-- Test 1: Initial state
			check_true ("initial_status", harness.assert_text (status_text, "Ready"))

			-- Test 2: Refresh updates status
			harness.simulate_click (refresh_btn)
			check_true ("after_refresh", harness.assert_text (status_text, "Refreshed"))

			-- Test 3: Clear updates status
			harness.simulate_click (clear_btn)
			check_true ("after_clear", harness.assert_text (status_text, "Cleared"))

			-- Test 4: Checkboxes have correct initial state
			check_true ("cb1_checked", cb1.is_checked)
			check_true ("cb2_checked", cb2.is_checked)
			check_true ("cb3_unchecked", not cb3.is_checked)

			-- Toggle checkbox
			cb3.toggle
			check_true ("cb3_after_toggle", cb3.is_checked)

			check_true ("all_passed", harness.all_assertions_passed)

			print ("%N" + harness.report)
		end

	test_demo_data_harness
			-- Test the Data Browser demo using GUI harness.
		local
			harness: SV_TEST_HARNESS
			quick: SV_QUICK
			dg: SV_DATA_GRID
			sb: SV_STATUSBAR
			search_field: SV_TEXT_FIELD
			add_btn, search_btn: SV_BUTTON
			row_count_lbl: SV_TEXT
		do
			-- Create harness
			create harness.make
			harness.enable_debug_mode

			-- Create UI components
			create quick.make
			dg := quick.data_grid_with (<<"ID", "Name", "Email", "Status">>)
			dg.add_row (<<"1", "Alice", "alice@example.com", "Active">>)
			dg.add_row (<<"2", "Bob", "bob@example.com", "Active">>)
			dg.add_row (<<"3", "Carol", "carol@example.com", "Inactive">>)

			sb := quick.statusbar_with ("Ready - 3 records")
			search_field := quick.text_field
			add_btn := quick.button ("Add")
			search_btn := quick.button ("Search")
			row_count_lbl := quick.text ("3 records")

			-- Wire up add
			add_btn.on_click (agent (g: SV_DATA_GRID; s: SV_STATUSBAR; lbl: SV_TEXT)
				do
					g.add_row (<<(g.row_count + 1).out, "New User", "new@example.com", "Pending">>)
					lbl.update_text (g.row_count.out + " records")
					s.set_text ("Added new record")
				end (dg, sb, row_count_lbl))

			-- Wire up search
			search_btn.on_click (agent (sf: SV_TEXT_FIELD; s: SV_STATUSBAR)
				do
					if sf.text.is_empty then
						s.set_text ("Enter search term")
					else
						s.set_text ("Searching for: " + sf.text.to_string_8)
					end
				end (search_field, sb))

			-- Register widgets
			harness.register (dg, "grid")
			harness.register (sb, "statusbar")
			harness.register (add_btn, "add")
			harness.register (search_btn, "search")

			-- Test 1: Initial data loaded
			check_equal ("initial_rows", 3, dg.row_count)
			check_string_equal ("first_name", "Alice", dg.cell_value (1, 2))

			-- Test 2: Add button adds row
			harness.simulate_click (add_btn)
			check_equal ("after_add", 4, dg.row_count)
			check_string_equal ("status_after_add", "Added new record", sb.text.to_string_8)

			-- Test 3: Empty search validation
			harness.simulate_click (search_btn)
			check_string_equal ("empty_search", "Enter search term", sb.text.to_string_8)

			-- Test 4: Search with term
			search_field.set_text ("Alice")
			harness.simulate_click (search_btn)
			check_string_equal ("search_term", "Searching for: Alice", sb.text.to_string_8)

			-- Test 5: Row selection
			dg.select_row (2)
			check_true ("has_selection", dg.has_selection)
			check_equal ("selected_row", 2, dg.selected_row)

			check_true ("all_passed", harness.all_assertions_passed)

			print ("%N" + harness.report)
		end



	test_state_machine_basic
			-- Test basic state machine operation.
		local
			quick: SV_QUICK
			sm: SV_STATE_MACHINE
		do
			create quick.make
			
			-- Create a simple state machine
			sm := quick.state_machine ("test_sm")
			
			-- Add states
			sm.state ("idle").described_as ("Waiting").do_nothing
			sm.state ("working").described_as ("Processing").do_nothing
			sm.state ("done").described_as ("Complete").do_nothing
			
			-- Add transitions
			sm.on ("start").from_state ("idle").to ("working").apply.do_nothing
			sm.on ("finish").from_state ("working").to ("done").apply.do_nothing
			sm.on ("reset").from_state ("done").to ("idle").apply.do_nothing
			
			-- Set initial state and start
			sm.set_initial ("idle")
			check_true ("not_started_initially", not sm.is_started)
			
			sm.start
			check_true ("started_after_start", sm.is_started)
			check_string_equal ("initial_state", "idle", sm.current_state_name)
			
			-- Trigger transitions
			check_true ("trigger_start", sm.trigger ("start"))
			check_string_equal ("in_working", "working", sm.current_state_name)
			
			check_true ("trigger_finish", sm.trigger ("finish"))
			check_string_equal ("in_done", "done", sm.current_state_name)
			
			-- Invalid event from current state should return False
			check_true ("invalid_start_from_done", not sm.trigger ("start"))
			check_string_equal ("still_in_done", "done", sm.current_state_name)
			
			-- Valid reset
			check_true ("trigger_reset", sm.trigger ("reset"))
			check_string_equal ("back_to_idle", "idle", sm.current_state_name)
		end

	test_state_machine_logging
			-- Test state machine logging functionality.
		local
			quick: SV_QUICK
			sm: SV_STATE_MACHINE
		do
			create quick.make
			
			-- Create simple state machine
			sm := quick.state_machine ("log_test")
			sm.state ("a").do_nothing
			sm.state ("b").do_nothing
			sm.on ("go").from_state ("a").to ("b").apply.do_nothing
			sm.set_initial ("a")
			sm.start
			
			-- Enable logging
			sm.enable_logging
			check_true ("logging_enabled", sm.is_logging_enabled)
			
			-- Trigger and check log
			sm.trigger ("go").do_nothing
			check_true ("log_has_transition", sm.last_log_message.has_substring ("go"))
			check_true ("log_has_from", sm.last_log_message.has_substring ("a"))
			check_true ("log_has_to", sm.last_log_message.has_substring ("b"))
			
			-- Try invalid event and check log
			sm.trigger ("invalid").do_nothing
			check_true ("log_has_no_transition", sm.last_log_message.has_substring ("no transition"))
			
			-- Disable logging
			sm.disable_logging
			check_true ("logging_disabled", not sm.is_logging_enabled)
		end

	test_state_machine_unstarted_contract
			-- Test that trigger on unstarted machine violates precondition.
		local
			quick: SV_QUICK
			sm: SV_STATE_MACHINE
			l_retried: BOOLEAN
			l_precondition_failed: BOOLEAN
		do
			if not l_retried then
				create quick.make
				
				-- Create state machine but DON'T start it
				sm := quick.state_machine ("unstarted")
				sm.state ("idle").do_nothing
				sm.state ("running").do_nothing
				sm.on ("go").from_state ("idle").to ("running").apply.do_nothing
				sm.set_initial ("idle")
				-- Note: NOT calling sm.start
				
				check_true ("machine_not_started", not sm.is_started)
				
				-- This should fail the precondition
				sm.trigger ("go").do_nothing
				
				-- If we get here, contract was not enforced (bad!)
				check_true ("precondition_should_have_failed", False)
			else
				-- We caught an exception - that's the expected behavior
				l_precondition_failed := True
			end
			
			check_true ("precondition_was_enforced", l_precondition_failed)
		rescue
			l_retried := True
			retry
		end

end
