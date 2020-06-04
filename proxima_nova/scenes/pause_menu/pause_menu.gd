extends CanvasLayer

onready var PauseMenu := $Control


func _process(delta: float) -> void:
	# pause and unpause
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		PauseMenu.visible = not PauseMenu.visible
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ExitGame_pressed():
	get_tree().quit()


func _on_RestartGame_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
