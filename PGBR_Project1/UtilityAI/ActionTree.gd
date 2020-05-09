class_name ActionTree
extends Node


onready var scene := get_tree().get_current_scene()


func get_best_action(employee):
	assert(get_child_count() == 0)
	get_child(0).get_score()
	return get_child(0).best_action
