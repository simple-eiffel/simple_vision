note
	description: "Hierarchical tree widget - wraps EV_TREE"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_TREE

inherit
	SV_WIDGET
		redefine
			apply_theme
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Create empty tree.
		do
			create ev_tree
			create nodes.make (20)
			node_counter := 0
			apply_theme
			subscribe_to_theme
		end

feature -- Access

	ev_tree: EV_TREE
			-- Underlying EiffelVision-2 tree.

	ev_widget: EV_WIDGET
			-- Implement SV_WIDGET requirement.
		do
			Result := ev_tree
		end

	count: INTEGER
			-- Number of root-level items.
		do
			Result := ev_tree.count
		end

	is_empty: BOOLEAN
			-- Is tree empty?
		do
			Result := ev_tree.is_empty
		end

	has_node (a_node_id: INTEGER): BOOLEAN
			-- Does node with ID exist?
		do
			Result := nodes.has (a_node_id)
		end

feature -- Selection

	selected_text: STRING_32
			-- Text of selected node.
		do
			if attached ev_tree.selected_item as al_node then
				Result := al_node.text
			else
				Result := {STRING_32} ""
			end
		end

	selected_value: STRING_32
			-- Value of selected node (stored in data field).
		do
			if attached ev_tree.selected_item as al_node and then attached {STRING_32} al_node.data as al_val then
				Result := al_val
			else
				Result := selected_text
			end
		end

	has_selection: BOOLEAN
			-- Is any node selected?
		do
			Result := ev_tree.selected_item /= Void
		end

feature -- Node Creation

	add_root (a_text: READABLE_STRING_GENERAL): INTEGER
			-- Add root-level node, return node ID for adding children.
		require
			text_not_empty: not a_text.is_empty
		local
			l_node: EV_TREE_ITEM
		do
			create l_node.make_with_text (a_text.to_string_32)
			l_node.set_data (a_text.to_string_32)

			ev_tree.extend (l_node)
			node_counter := node_counter + 1
			nodes.put (l_node, node_counter)
			Result := node_counter
		ensure
			added: count = old count + 1
			valid_id: Result > 0
		end

	add_root_with_value (a_text, a_value: READABLE_STRING_GENERAL): INTEGER
			-- Add root node with separate display text and value.
		require
			text_not_empty: not a_text.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_node: EV_TREE_ITEM
		do
			create l_node.make_with_text (a_text.to_string_32)
			l_node.set_data (a_value.to_string_32)

			ev_tree.extend (l_node)
			node_counter := node_counter + 1
			nodes.put (l_node, node_counter)
			Result := node_counter
		end

	add_child (a_parent_id: INTEGER; a_text: READABLE_STRING_GENERAL): INTEGER
			-- Add child node to parent, return node ID.
		require
			valid_parent: has_node (a_parent_id)
			text_not_empty: not a_text.is_empty
		local
			l_node: EV_TREE_ITEM
		do
			if attached nodes.item (a_parent_id) as al_parent then
				create l_node.make_with_text (a_text.to_string_32)
				l_node.set_data (a_text.to_string_32)
	
				al_parent.extend (l_node)
				node_counter := node_counter + 1
				nodes.put (l_node, node_counter)
				Result := node_counter
			end
		end

	add_child_with_value (a_parent_id: INTEGER; a_text, a_value: READABLE_STRING_GENERAL): INTEGER
			-- Add child node with separate display text and value.
		require
			valid_parent: has_node (a_parent_id)
			text_not_empty: not a_text.is_empty
			value_not_empty: not a_value.is_empty
		local
			l_node: EV_TREE_ITEM
		do
			if attached nodes.item (a_parent_id) as al_parent then
				create l_node.make_with_text (a_text.to_string_32)
				l_node.set_data (a_value.to_string_32)
	
				al_parent.extend (l_node)
				node_counter := node_counter + 1
				nodes.put (l_node, node_counter)
				Result := node_counter
			end
		end

feature -- Bulk Operations

	add_roots (a_items: ARRAY [READABLE_STRING_GENERAL]): like Current
			-- Add multiple root nodes.
		require
			items_attached: a_items /= Void
		do
			across a_items as ic_item loop
				add_root (ic_item.item).do_nothing
			end
			Result := Current
		ensure
			result_is_current: Result = Current
		end

	clear
			-- Remove all nodes.
		do
			ev_tree.wipe_out
			nodes.wipe_out
			node_counter := 0
		ensure
			empty: is_empty
		end

feature -- Selection Operations

	select_node (a_node_id: INTEGER)
			-- Select specific node by ID.
		require
			valid_id: has_node (a_node_id)
		do
			if attached nodes.item (a_node_id) as al_node then
				al_node.enable_select
				notify_selection_change
			end
		end

	deselect_all
			-- Clear selection.
		do
			if attached ev_tree.selected_item as al_node then
				al_node.disable_select
			end
		ensure
			no_selection: not has_selection
		end

feature -- Expansion

	expand_all
			-- Expand all nodes.
		do
			across ev_tree as ic_node loop
				expand_recursive (ic_node.item)
			end
		end

	collapse_all
			-- Collapse all nodes.
		do
			across ev_tree as ic_node loop
				collapse_recursive (ic_node.item)
			end
		end

	expand_node (a_node_id: INTEGER)
			-- Expand specific node.
		require
			valid_id: has_node (a_node_id)
		do
			if attached nodes.item (a_node_id) as al_node then
				al_node.expand
			end
		end

	collapse_node (a_node_id: INTEGER)
			-- Collapse specific node.
		require
			valid_id: has_node (a_node_id)
		do
			if attached nodes.item (a_node_id) as al_node then
				al_node.collapse
			end
		end

feature -- Events

	on_select (a_action: PROCEDURE)
			-- Set action for selection change.
		require
			action_attached: a_action /= Void
		do
			ev_tree.select_actions.extend (a_action)
		end

	on_deselect (a_action: PROCEDURE)
			-- Set action for deselection.
		require
			action_attached: a_action /= Void
		do
			ev_tree.deselect_actions.extend (a_action)
		end

	on_double_click (a_action: PROCEDURE)
			-- Set action for double-click.
		require
			action_attached: a_action /= Void
		do
			ev_tree.pointer_double_press_actions.extend (agent (x, y, b: INTEGER; xt, yt, p: REAL_64; sx, sy: INTEGER; act: PROCEDURE)
				do
					act.call (Void)
				end (?, ?, ?, ?, ?, ?, ?, ?, a_action))
		end

	selected_action (a_action: PROCEDURE): like Current
			-- Fluent version of on_select.
		require
			action_attached: a_action /= Void
		do
			on_select (a_action)
			Result := Current
		ensure
			result_is_current: Result = Current
		end

feature -- Theme

	apply_theme
			-- Apply theme colors to tree.
		do
			ev_tree.set_foreground_color (tokens.text_primary.to_ev_color)
			ev_tree.set_background_color (tokens.surface.to_ev_color)
		end

feature {NONE} -- Implementation

	nodes: HASH_TABLE [EV_TREE_ITEM, INTEGER]
			-- All nodes by ID.

	node_counter: INTEGER
			-- Counter for generating node IDs.

	expand_recursive (a_node: EV_TREE_NODE)
			-- Expand node and all children.
		do
			a_node.expand
			across a_node as ic_child loop
				expand_recursive (ic_child.item)
			end
		end

	collapse_recursive (a_node: EV_TREE_NODE)
			-- Collapse node and all children.
		do
			across a_node as ic_child loop
				collapse_recursive (ic_child.item)
			end
			a_node.collapse
		end

	notify_selection_change
			-- Notify harness of selection change.
		do
			if is_instrumented then
				notify_event (create {SV_EVENT}.make_state_change ("selection", "", selected_value))
			end
		end

invariant
	ev_tree_exists: ev_tree /= Void
	nodes_exists: nodes /= Void

end
