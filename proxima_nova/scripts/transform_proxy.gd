tool
class_name TransformProxy
extends Spatial


export var initial_transform: Transform setget set_initial_transform

var dont_save = ["initial_transform", "_affine_transform"]

var _affine_transform: Transform


func _ready():
	if initial_transform.is_equal_approx(Transform.IDENTITY):
		set_initial_transform(transform)


func set_initial_transform(transform: Transform):
	initial_transform = transform
	_affine_transform = transform.affine_inverse()


func _process(_delta):
	get_parent().transform *= transform * _affine_transform
	transform = initial_transform
