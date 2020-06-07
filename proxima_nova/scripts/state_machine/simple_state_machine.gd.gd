extends Node
class_name SimpleStateMachine

var state = null setget set_state
var previous_state = null

onready var parent = get_parent()


func _process(delta: float) -> void:
	if state != null:
		_state_logic(delta)


func _state_logic(delta: float) -> void:
	pass


func _get_transition(delta: float):
	return null


func _enter_state(new_state, old_state) -> void:
	pass


func _exit_state(old_state, new_state) -> void:
	pass


func set_state(new_state) -> void:
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)
	pass
