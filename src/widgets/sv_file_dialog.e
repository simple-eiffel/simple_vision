note
	description: "File open/save dialog - wraps EV_FILE_OPEN_DIALOG and EV_FILE_SAVE_DIALOG"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_FILE_DIALOG

inherit
	SV_ANY

create
	make_open,
	make_save

feature {NONE} -- Initialization

	make_open
			-- Create file open dialog.
		do
			create ev_open_dialog
			is_open_dialog := True
			create filters.make (5)
		end

	make_save
			-- Create file save dialog.
		do
			create ev_save_dialog
			is_open_dialog := False
			create filters.make (5)
		end

feature -- Access

	ev_open_dialog: detachable EV_FILE_OPEN_DIALOG
			-- Underlying open dialog.

	ev_save_dialog: detachable EV_FILE_SAVE_DIALOG
			-- Underlying save dialog.

	is_open_dialog: BOOLEAN
			-- Is this an open dialog?

	is_save_dialog: BOOLEAN
			-- Is this a save dialog?
		do
			Result := not is_open_dialog
		end

	file_name: STRING_32
			-- Selected file name (full path).
		do
			if is_open_dialog then
				check attached ev_open_dialog as d then
					Result := d.file_name
				end
			else
				check attached ev_save_dialog as d then
					Result := d.file_name
				end
			end
		end

	file_path: STRING_32
			-- Alias for file_name.
		do
			Result := file_name
		end

	file_title: STRING_32
			-- Just the file name without path.
		do
			Result := file_name
			if Result.has ('\') then
				Result := Result.substring (Result.last_index_of ('\', Result.count) + 1, Result.count)
			elseif Result.has ('/') then
				Result := Result.substring (Result.last_index_of ('/', Result.count) + 1, Result.count)
			end
		end

	has_file: BOOLEAN
			-- Was a file selected?
		do
			Result := not file_name.is_empty
		end

feature -- Configuration

	set_title (a_title: STRING)
			-- Set dialog title.
		require
			title_not_empty: not a_title.is_empty
		do
			if is_open_dialog then
				check attached ev_open_dialog as d then
					d.set_title (a_title)
				end
			else
				check attached ev_save_dialog as d then
					d.set_title (a_title)
				end
			end
		end

	title (a_title: STRING): like Current
			-- Set title (fluent).
		require
			title_not_empty: not a_title.is_empty
		do
			set_title (a_title)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_start_directory (a_path: STRING)
			-- Set initial directory.
		require
			path_not_empty: not a_path.is_empty
		do
			if is_open_dialog then
				check attached ev_open_dialog as d then
					d.set_start_directory (a_path)
				end
			else
				check attached ev_save_dialog as d then
					d.set_start_directory (a_path)
				end
			end
		end

	start_directory (a_path: STRING): like Current
			-- Set start directory (fluent).
		require
			path_not_empty: not a_path.is_empty
		do
			set_start_directory (a_path)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	set_file_name (a_name: STRING)
			-- Set default file name.
		require
			name_not_empty: not a_name.is_empty
		do
			if is_open_dialog then
				check attached ev_open_dialog as d then
					d.set_file_name (a_name)
				end
			else
				check attached ev_save_dialog as d then
					d.set_file_name (a_name)
				end
			end
		end

	default_name (a_name: STRING): like Current
			-- Set default file name (fluent).
		require
			name_not_empty: not a_name.is_empty
		do
			set_file_name (a_name)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Filters

	filters: ARRAYED_LIST [TUPLE [description: STRING; pattern: STRING]]
			-- File filters.

	add_filter (a_description, a_pattern: STRING)
			-- Add a file filter.
		require
			description_not_empty: not a_description.is_empty
			pattern_not_empty: not a_pattern.is_empty
		do
			filters.extend ([a_description, a_pattern])
			if is_open_dialog then
				check attached ev_open_dialog as d then
					d.filters.extend ([a_description, a_pattern])
				end
			else
				check attached ev_save_dialog as d then
					d.filters.extend ([a_description, a_pattern])
				end
			end
		end

	filter (a_description, a_pattern: STRING): like Current
			-- Add filter (fluent).
		require
			description_not_empty: not a_description.is_empty
			pattern_not_empty: not a_pattern.is_empty
		do
			add_filter (a_description, a_pattern)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	all_files: like Current
			-- Add "All Files (*.*)" filter.
		do
			Result := filter ("All Files (*.*)", "*.*")
		ensure
			result_is_current: Result = Current
		end

	text_files: like Current
			-- Add text files filter.
		do
			Result := filter ("Text Files (*.txt)", "*.txt")
		ensure
			result_is_current: Result = Current
		end

	eiffel_files: like Current
			-- Add Eiffel files filter.
		do
			Result := filter ("Eiffel Files (*.e)", "*.e")
		ensure
			result_is_current: Result = Current
		end

	json_files: like Current
			-- Add JSON files filter.
		do
			Result := filter ("JSON Files (*.json)", "*.json")
		ensure
			result_is_current: Result = Current
		end

	xml_files: like Current
			-- Add XML files filter.
		do
			Result := filter ("XML Files (*.xml)", "*.xml")
		ensure
			result_is_current: Result = Current
		end

	image_files: like Current
			-- Add common image files filter.
		do
			Result := filter ("Image Files (*.png;*.jpg;*.gif;*.bmp)", "*.png;*.jpg;*.gif;*.bmp")
		ensure
			result_is_current: Result = Current
		end

feature -- Display

	show (a_parent: SV_WINDOW)
			-- Show dialog modal to parent.
		require
			parent_attached: a_parent /= Void
		do
			if is_open_dialog then
				check attached ev_open_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
				end
			else
				check attached ev_save_dialog as d then
					d.show_modal_to_window (a_parent.ev_titled_window)
				end
			end
		end

	show_and_get_file (a_parent: SV_WINDOW): STRING_32
			-- Show dialog and return selected file (empty if cancelled).
		require
			parent_attached: a_parent /= Void
		do
			show (a_parent)
			Result := file_name
		end

invariant
	one_dialog: (ev_open_dialog /= Void) xor (ev_save_dialog /= Void)
	filters_exists: filters /= Void

end
