class_name Action
extends Node


func get_action_tree() -> ActionTree:
	if not get_parent() is ActionTree:
		return get_parent().get_action_tree()
	
	return get_parent() as ActionTree


func get_score(employee) -> float:
	# employee is the node that is asking for the best action to do
	# this function returns how much 'value' there is when using the best_action offered by this script
	return 0.0


func get_action(employee) -> Reference:
	return ActionInterface.new(employee)


class ActionInterface:
	var employee
	
	func _init(node):
		employee = node
	
	func process(delta) -> int:
		return OK
	
	func end() -> void:
		return

