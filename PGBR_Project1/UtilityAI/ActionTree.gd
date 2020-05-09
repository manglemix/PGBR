class_name ActionTree
extends Node


export(String) var group
export var active := true		# if true, all nodes in the group will be controlled by this node

var assigned_nodes := {}


func get_best_action(employee):
	assert(get_child_count() == 0)
	get_child(0).get_score(employee)
	return get_child(0).best_action


func _process(delta):
	if active:
		var nodes := get_tree().get_nodes_in_group(group)
		# TODO FINISH
