extends Spatial


export(Array, Transform) var transforms := []

var transform_index := 0 setget set_transform_index


func _ready():
	transforms.insert(0, transform)


func set_transform_index(index: int):
	transform_index = index
	transform = transforms[transform_index]


func increment_transform():
	transform_index += 1
	if transform_index >= len(transforms):
		transform_index = 0
	transform = transforms[transform_index]


func decrement_transform():
	transform_index -= 1
	if transform_index <= 0:
		transform_index = len(transform_index) - 1
	transform = transforms[transform_index]
