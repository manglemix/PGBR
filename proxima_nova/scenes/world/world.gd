extends Spatial

var title = "Proxima Nova v0.1"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().use_font_oversampling = true


func _process(delta):
	# restart game
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))
