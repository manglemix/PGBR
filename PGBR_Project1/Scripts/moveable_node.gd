class_name MoveableNode
extends Spatial


signal reached_target

export(Array, Transform) var transforms := []
export var interpolate_speed := 6.0
export var interpolated := false

var transform_index := 0 setget set_transform_index
var target_transform: Transform setget goto


func _ready():
	transforms = transforms.duplicate()
	transforms.insert(0, transform)
	set_process(false)


func goto(target: Transform):
	transforms.clear()
	if interpolated:
		set_process(true)
	
	if interpolated:
		target_transform = target
	else:
		transform = target


func set_transform_index(index: int):
	transform_index = index
	if interpolated:
		set_process(true)
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func increment_transform():
	transform_index += 1
	if interpolated:
		set_process(true)
	
	if transform_index >= len(transforms):
		transform_index = 0
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func decrement_transform():
	transform_index -= 1
	if interpolated:
		set_process(true)
	
	if transform_index <= 0:
		transform_index = len(transform_index) - 1
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func _process(delta):
	transform = transform.interpolate_with(target_transform, interpolate_speed * delta)
	
	if transform.origin.distance_to(target_transform.origin) < 0.01:
		emit_signal("reached_target")
		set_process(false)
