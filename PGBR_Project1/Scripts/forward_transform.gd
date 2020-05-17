# any transformation done to this node will be applied to the parent
class_name ForwardTransform
extends Spatial


onready var initial_transform := transform


func _process(delta):
	get_parent().global_transform = global_transform * initial_transform.affine_inverse()
	transform = initial_transform
