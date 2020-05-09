class_name ActionTree
extends Node


export(String) var group
export var active := true		# if true, all nodes in the group will be controlled by this node

var assigned_nodes := {}


func get_best_action(employee):
	assert(get_child_count() == 0)
	get_child(0).get_score(employee)
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
		# TODO FINISH
