extends CanvasLayer

signal finished_fading

export var is_faded := true setget set_is_faded, get_is_faded
export var duration := 1.0

var alpha := 1.0

onready var Fade := $Fade/Fade as ColorRect


func set_is_faded(new_val: bool) -> void:
	is_faded = new_val
	set_process(true)


func get_is_faded() -> bool:
	return is_faded


func _process(delta: float) -> void:
	# either fade in or fade out
	if is_faded:
		if alpha < 1.0:
			alpha = clamp(alpha + (delta / duration), 0.0, 1.0)
		else:
			set_process(false)
			emit_signal("finished_fading")
	else:
		if alpha > 0.0:
			alpha = clamp(alpha - (delta / duration), 0.0, 1.0)
		else:
			set_process(false)
			emit_signal("finished_fading")
	
	# update our color
	Fade.color = Color(0.0, 0.0, 0.0, alpha)
	
	# until we're fully transparent, keep this visible
	Fade.visible = alpha > 0.0
