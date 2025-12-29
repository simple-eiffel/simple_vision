note
	description: "Demo: Data Grid with sorting and zebra striping"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	DEMO_GRID

inherit
	SV_QUICK
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create demo.
		local
			l_app: SV_APPLICATION
			l_win: SV_WINDOW
		do
			Precursor
			l_win := build_ui
			create l_app.make
			l_app.add_window (l_win)
			l_win.show_now
			l_app.launch
		end

feature {NONE} -- UI Building

	build_ui: SV_WINDOW
			-- Build the main UI.
		local
			l_col: SV_COLUMN
			l_theme_btn, l_stripe_btn, l_add_btn: SV_BUTTON
			l_grid: SV_DATA_GRID
			l_status: SV_TEXT
		do
			-- Create window
			Result := window ("Data Grid Demo").size (800, 600)

			-- Create buttons with actions
			l_theme_btn := button ("Toggle Dark Mode")
			l_theme_btn.on_click (agent toggle_theme)
			l_stripe_btn := button ("Toggle Striping")
			l_stripe_btn.on_click (agent toggle_striping)
			l_add_btn := button ("Add Random Row")
			l_add_btn.on_click (agent add_random_row)

			-- Create data grid
			l_grid := data_grid
				.columns (<<"Name", "Department", "Salary", "Start Date">>)
				.sortable
				.striped
			the_grid := l_grid

			-- Add sample data
			l_grid.add_row (<<"Alice Smith", "Engineering", "85000", "2020-03-15">>)
			l_grid.add_row (<<"Bob Johnson", "Marketing", "72000", "2019-08-22">>)
			l_grid.add_row (<<"Carol White", "Engineering", "92000", "2018-01-10">>)
			l_grid.add_row (<<"David Brown", "Sales", "68000", "2021-06-01">>)
			l_grid.add_row (<<"Emma Davis", "Engineering", "78000", "2022-02-14">>)
			l_grid.add_row (<<"Frank Miller", "Marketing", "65000", "2020-11-30">>)
			l_grid.add_row (<<"Grace Lee", "Sales", "71000", "2019-04-18">>)
			l_grid.add_row (<<"Henry Wilson", "Engineering", "95000", "2017-09-05">>)
			l_grid.add_row (<<"Iris Taylor", "HR", "58000", "2021-12-01">>)
			l_grid.add_row (<<"Jack Anderson", "Sales", "82000", "2018-07-20">>)

			-- Set column widths
			l_grid.set_column_width (1, 150)
			l_grid.set_column_width (2, 120)
			l_grid.set_column_width (3, 100)
			l_grid.set_column_width (4, 120)

			-- Create status label
			l_status := text (l_grid.row_count.out)
			status_label := l_status

			-- Main column layout with all content
			l_col := column.spacing (10).padding (20)
				.add (text ("Data Grid Demo - Sorting & Striping").bold.font_size (18))
				.add (row.spacing (10).add (text ("Theme:")).add (l_theme_btn))
				.add (divider)
				.add (row.spacing (10).add (l_stripe_btn).add (l_add_btn).add (text ("(Click headers to sort)")))
				.add (l_grid)
				.expand_child (l_grid)
				.add (row.spacing (10)
					.add (text ("Rows:"))
					.add (l_status)
					.add (spacer)
					.add (text ("(Click header to sort)")))

			Result.extend (l_col)
		end

feature {NONE} -- Actions

	toggle_theme
			-- Toggle between light and dark mode.
		do
			theme.toggle_dark_mode
		end

	toggle_striping
			-- Toggle zebra striping.
		do
			if attached the_grid as g then
				if g.is_striped then
					g.disable_striping
				else
					g.enable_striping
				end
			end
		end

	add_random_row
			-- Add a random row.
		local
			l_names: ARRAY [STRING]
			l_depts: ARRAY [STRING]
			l_rand: RANDOM
			l_name, l_dept, l_salary, l_date: STRING
		do
			l_names := <<"John", "Jane", "Michael", "Sarah", "Robert", "Linda">>
			l_depts := <<"Engineering", "Marketing", "Sales", "HR", "Finance">>

			create l_rand.set_seed ((create {TIME}.make_now).compact_time)
			l_rand.forth

			l_name := l_names [(l_rand.item \\ l_names.count) + 1] + " New"
			l_rand.forth
			l_dept := l_depts [(l_rand.item \\ l_depts.count) + 1]
			l_rand.forth
			l_salary := ((l_rand.item \\ 50000) + 50000).out
			l_date := "2024-" + ((l_rand.item \\ 12) + 1).out + "-01"

			if attached the_grid as g then
				g.add_row (<<l_name, l_dept, l_salary, l_date>>)
				if attached status_label as lbl then
					lbl.update_text (g.row_count.out)
				end
			end
		end

feature {NONE} -- UI Elements

	the_grid: detachable SV_DATA_GRID
			-- The data grid.

	status_label: detachable SV_TEXT
			-- Status label showing row count.

end
