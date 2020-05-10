class_name Action
extends Node


var employee					# this value is forcefully set by Maximiser or ActionTree


func get_score() -> float:
	# employee is the node that is asking for the best action to do
	# this function returns how much 'value' there is when using the best_action offered by this script
	return 0.0


class ActionInterface:
	var employee
	
	func _init(node):
		employee = node
	
	func process(delta) -> int:
		return OK
	
	func end():
		return


func get_best_action(employee) -> Reference:
	return ActionInterface.new(employee)
