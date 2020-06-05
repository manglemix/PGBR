extends Control

onready var compass := $CompassMeter as Sprite
onready var player := get_tree().get_root().find_node("Player", true, false) as Player

func _process(delta):
	compass.region_rect.position.x = Utils.map(
		player.rotation_degrees.y, -180, 180, 
		-compass.region_rect.size.x/2,
		compass.region_rect.size.x/2
	)
