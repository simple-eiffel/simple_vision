note
	description: "Data browser demo for simple_vision (Phase 4)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_DATA

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Run the Data Browser demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor

			-- Create widgets with IDs for testing
			data_grid_widget := data_grid_with (<<"ID", "Name", "Email", "Status">>).id ("grid_data")
			data_grid_widget.add_row (<<"1", "Alice Smith", "alice@example.com", "Active">>)
			data_grid_widget.add_row (<<"2", "Bob Jones", "bob@example.com", "Active">>)
			data_grid_widget.add_row (<<"3", "Carol White", "carol@example.com", "Inactive">>)
			data_grid_widget.add_row (<<"4", "David Brown", "david@example.com", "Active">>)
			data_grid_widget.add_row (<<"5", "Eve Green", "eve@example.com", "Pending">>)

			status_bar_widget := statusbar_with ("Ready - 5 records loaded").id ("statusbar_main")
			search_field := text_field.id ("field_search")
			row_count_label := text ("5 records").id ("label_count")
			add_button := button ("Add").id ("button_add")
			edit_button := button ("Edit").id ("button_edit")
			delete_button := button ("Delete").id ("button_delete")
			search_button := button ("Search").id ("button_search")

			-- Build the UI
			l_win := window ("Data Browser - simple_vision Demo")
				.size (800, 500)
				.centered
				.content (
					column.children (<<
						-- Toolbar row
						row.spacing (5).padding (5).children (<<
							add_button.clicked (agent on_add),
							edit_button.clicked (agent on_edit),
							delete_button.clicked (agent on_delete),
							separator_vertical,
							search_field.placeholder ("Search...").min_width (200),
							search_button.clicked (agent on_search),
							spacer,
							row_count_label
						>>),
						divider,
						-- Data grid
						data_grid_widget.single_selection,
						-- Status bar
						status_bar_widget
					>>)
				)

			-- Wire up selection event
			data_grid_widget.on_row_select (agent on_row_select)

			-- Create application and launch
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature -- Widget References (for testing)

	data_grid_widget: SV_DATA_GRID
	status_bar_widget: SV_STATUSBAR
	search_field: SV_TEXT_FIELD
	row_count_label: SV_TEXT
	add_button: SV_BUTTON
	edit_button: SV_BUTTON
	delete_button: SV_BUTTON
	search_button: SV_BUTTON
	next_id: INTEGER

feature {NONE} -- Event Handlers

	on_add
			-- Handle add button.
		do
			next_id := data_grid_widget.row_count + 1
			data_grid_widget.add_row (<<next_id.out, "New User", "new@example.com", "Pending">>)
			update_count
			status_bar_widget.set_text ("Added new record")
		end

	on_edit
			-- Handle edit button.
		do
			if data_grid_widget.has_selection then
				status_bar_widget.set_text ("Editing row " + data_grid_widget.selected_row.out)
			else
				status_bar_widget.set_text ("Select a row to edit")
			end
		end

	on_delete
			-- Handle delete button.
		do
			if data_grid_widget.has_selection then
				status_bar_widget.set_text ("Delete not implemented in demo")
			else
				status_bar_widget.set_text ("Select a row to delete")
			end
		end

	on_search
			-- Handle search button.
		do
			if search_field.text.is_empty then
				status_bar_widget.set_text ("Enter search term")
			else
				status_bar_widget.set_text ("Searching for: " + search_field.text.to_string_8)
			end
		end

	on_row_select
			-- Handle row selection.
		do
			if data_grid_widget.has_selection then
				status_bar_widget.set_text ("Selected row " + data_grid_widget.selected_row.out +
					": " + data_grid_widget.cell_value (data_grid_widget.selected_row, 2))
			end
		end

	update_count
			-- Update record count display.
		do
			row_count_label.update_text (data_grid_widget.row_count.out + " records")
		end

end
