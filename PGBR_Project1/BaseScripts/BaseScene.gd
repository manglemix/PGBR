extends Spatial

signal player_changed(node)

export var enable_debug := false
export var player_path: NodePath


func _ready():
	Debug.enabled = enable_debug
	Director.set_player(get_node(player_path))
