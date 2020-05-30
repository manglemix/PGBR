# Provides and easy way to move a node to several pre-defined transforms
class_name MoveableNode
extends Spatial


signal reached_target	# emitted when the target transform is reached

export(Array, Transform) var transforms := []	# transforms, relative to the parent, that his node can move to
export var interpolate_speed := 6.0		# the speed at which this node interpolates to target transforms
export var interpolated := false		# if true, the node will interpolate to target transforms, else it will just teleport to them

var transform_index := 0 setget set_transform_index		# the index in the transforms array that is the target transform
var target_transform: Transform setget goto		# the current transform the node is trying to get to, or is already at


func _ready():
	transforms = transforms.duplicate()
	transforms.insert(0, transform)
	set_process(false)


func goto(target: Transform):
	# moves the node towards a local transform
	if interpolated:
		set_process(true)
	
	if interpolated:
		target_transform = target
	else:
		transform = target


func global_goto(target: Transform):
	# moves the node towards a global transform
	# if the parent moves in the process, the endpoint will move too
	if interpolated:
		set_process(true)
	
	if interpolated:
		target_transform = target * get_parent().global_transform.affine_inverse()
	else:
		transform = target * get_parent().global_transform.affine_inverse()


func set_transform_index(index: int):
	# sets the target transform to the transform in the transforms array at the index given
	transform_index = index
	if interpolated:
		set_process(true)
	
	if interpolated:
		target_transform = transforms[transform_index]
	else:
		transform = transforms[transform_index]


func increment_transform():
	# inreases transform index by 1
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
	# decreases transform index by 1
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
