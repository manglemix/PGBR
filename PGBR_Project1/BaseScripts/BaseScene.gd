extends Spatial

signal player_changed(node)

export var enable_debug := false

var player setget set_player


func _ready():
	Debug.enabled = enable_debug


func set_player(node):
	player = node
	emit_signal("player_changed", node)
