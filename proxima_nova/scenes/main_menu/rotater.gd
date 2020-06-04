tool
extends Spatial

export var rotation_speed := 0.5

func _process(delta):
	rotate_y(rotation_speed * delta)
