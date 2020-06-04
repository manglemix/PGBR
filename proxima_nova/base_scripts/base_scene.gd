extends Spatial


export(Array, NodePath) var _jump_paths := []

var dont_save := ["jump_pads"]
var jump_pads := []


func _ready():
	for path in _jump_paths:
		jump_pads.append(get_node(path))
