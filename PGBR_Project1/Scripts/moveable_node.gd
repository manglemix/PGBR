class_name MoveableNode
extends Spatial


signal reached_target

export(Array, Transform) var transforms := []
export var interpolate_speed := 6.0
export var interpolated := false setget set_interpolated

var transform_index := 0 setget set_transform_index
var target_transform: Transform setget goto


func _ready():
	transforms = transforms.duplicate()
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


func _process(delta):
	global_transform = global_transform.interpolate_with(target_transform, interpolate_speed * delta)
	
	if global_transform.origin.distance_to(target_transform.origin) < 0.05 and global_transform.basis.tdotz(target_transform.basis.z) >= 0.99:
		emit_signal("reached_target")
