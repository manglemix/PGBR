extends Spatial

signal player_changed(node)

export var player_path: NodePath


func _ready():
	Director.set_player(get_node(player_path))
