class_name State
extends Node


var father: UtilityTree
onready var scene := get_tree().get_current_scene()


func get_score(_employee) -> float:
	return 0.0


func get_state(_employee):
	return duplicate()


func _ready():
	# by default, the _process node will only activate if the State was assigned to an employee
	# in that case, the StateTree will activate it
	set_process(false)
	add_to_group("ignore_state")
	
	if get_parent() is UtilityTree:
		father = get_parent()
		
	elif "father" in get_parent():
		father = get_parent().father
	
	else:
		father = null


#func _process(delta):
#	# code that goes here is run when this node gets assigned to a node (which is then called an employee)
#	pass
