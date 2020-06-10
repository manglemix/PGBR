extends CameraState
# Rotates the camera around the character, delegating all the work to its parent state.


func input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_aim"):
		_state_machine.transition_to("Camera/Aim")
	else:
		_parent.input(event)


func process(delta: float) -> void:
	_parent.process(delta)
