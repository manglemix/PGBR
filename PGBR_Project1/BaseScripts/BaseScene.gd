extends Spatial


export var enable_debug := false


func _ready():
	Debug.enabled = enable_debug
