class_name ActionTree
extends Node


enum {CAN_CHANGE = 1, MUST_CHANGE = 2}

export(String) var my_group
export var active := true		# if true, all employees in the my_group will be controlled by this node

var assigned_nodes := {}

onready var scene := get_tree().get_current_scene()


func get_best_action(employee) -> Reference:
	assert(get_child_count() == 1)
	get_child(0).get_score(employee)		# sometimes some employees need to calculate their score first
	return get_child(0).get_action(employee) as Reference


func assign_node(node, action: Reference) -> void:
	if node in assigned_nodes:
		unassign_node(node)
	
	assigned_nodes[node] = action


func unassign_node(node) -> void:
	var action = assigned_nodes[node]
	action.end()
	assigned_nodes.erase(node)


func _process(delta):
	if active:
		var employees := get_tree().get_nodes_in_group(my_group)
		
		# checks if the employees (employees to be controlled) are still valid, and are still in the same my_group
		var remove_nodes := []
		for node in assigned_nodes:
			if (not node in employees) or (not is_instance_valid(node)):
				remove_nodes.append(node)
		
		# employees must be removed in a separate loop otherwise it may cause the iteration to crash
		for node in remove_nodes:
			unassign_node(node)
		
		# if a node in the my_group is not assigned, assign it with the best action
		for node in employees:
			if not node in assigned_nodes:
				assign_node(node, get_best_action(node))
		
		# this executes all the assigned actions
		var output: int
		var action
		for node in assigned_nodes:
			action = assigned_nodes[node]
			output = action.process(delta)
			
			if output == CAN_CHANGE:
				var new_action = get_best_action(node)
				# if the new best action is actually just the same action, then don't reset
				# however if it is different, replace the current action
				if typeof(action) != typeof(new_action):
					assign_node(node, new_action)
			
			elif output == MUST_CHANGE:
				# if the node is removed, it will be reassigned next frame
				unassign_node(node)
