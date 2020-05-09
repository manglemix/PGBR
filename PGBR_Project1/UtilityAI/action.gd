class_name Action
extends Node


const CAN_CHANGE := 1			# this node can be changed, but can also remain the as the current action without resetting
const MUST_CHANGE := 2			# this node must be reset if ran again, or it another node can take over

var best_action = self
var employee					# this value is forcefully set by Maximiser or ActionTree


func get_score() -> float:
	# employee is the node that is asking for the best action to do
	# this function returns how much 'value' there is when using the best_action offered by this script
	return 0.0


func reset() -> void:
	# if there are any variables that must be reset so that the employee given can run
	return


func execute() -> int:
	# runs the code which causes employee to complete a task
	# must return an error code to alert the ActionTree to check for the best action again
	return OK
