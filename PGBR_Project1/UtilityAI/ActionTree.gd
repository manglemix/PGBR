class_name ActionTree
extends Node


const CAN_CHANGE := 1			# this node can be changed, but can also remain the as the current action without resetting
const MUST_CHANGE := 2			# this node must be reset if ran again, or it another node can take over
enum {CAN_CHANGE = 1, MUST_CHANGE = 2}

export(String) var group
export var active := true		# if true, all nodes in the group will be controlled by this node

var assigned_nodes := {}


func get_best_action(employee):
	assert(get_child_count() == 1)
	get_child(0).get_score()
	return get_child(0).best_action


func assign_node(node, action):
	if node in assigned_nodes:
		unassign_node(node)
	
	assigned_nodes[node] = action
	action.employee = node
	action.reset()


func unassign_node(node):
	var action = assigned_nodes[node]
	action.end()
	assigned_nodes.erase(node)


func _process(delta):
	if active:
		var nodes := get_tree().get_nodes_in_group(group)
		
		# checks if the employees (nodes to be controlled) are still valid, and are still in the same group
		var remove_nodes := []
		for node in assigned_nodes:
			if (not node in nodes) or (not is_instance_valid(node)):
				remove_nodes.append(node)
		
		# nodes must be removed in a separate loop otherwise it may cause the iteration to crash
		for node in remove_nodes:
			unassign_node(node)
		
		# if a node in the group is not assigned, assign it with the best action
		for node in nodes:
			if not node in assigned_nodes:
				assign_node(node, get_best_action(node))
		
		# this executes all the assigned actions
		var output: int
		var action
		for node in assigned_nodes:
			action = assigned_nodes[node]
			output = action.execute()
			
			if output == CAN_CHANGE:
				var new_action = get_best_action(node)
				# if the new best action is actually just the same action, then don't reset
				# however if it is different, replace the current action
				if typeof(action) != typeof(new_action):
					assign_node(node, new_action)
			
			elif output == MUST_CHANGE:
				# if the node is removed, it will be reassigned next frame
				unassign_node(node)
