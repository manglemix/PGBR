class_name MoveableNode
extends Spatial


export(Array, Transform) var transforms := []

var transform_index := 0 setget set_transform_index


func _ready():
	transforms.insert(0, transform)
	set_process(interpolated)


func set_interpolated(value: bool):
	set_process(value)
	interpolated = value


func goto(target: Transform):
	transforms.clear()
	if interpolated:
		target_transform = target
	else:
		transform = target


func set_transform_index(index: int):
	transform_index = index
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func increment_transform():
	transform_index += 1
	if transform_index >= len(transforms):
		transform_index = 0
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func decrement_transform():
	transform_index -= 1
	if transform_index <= 0:
		transform_index = len(transform_index) - 1
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]
