class_name PivotPoint
extends Spatial


export var max_pitch := 70.0
export var min_pitch := - 70.0
export var max_yaw := 45.0
export var min_yaw := -45.0
export var limit_pitch := true
export var limit_yaw := false
export var turn_speed := 6.0
export var fallback_node_path: NodePath # This is the node where extra rotation is applied to

var _target_transform: Transform

onready var _initial_transform := transform


func _ready():
	set_process(false)


func biaxial_rotate(x: float, y: float) -> void:
	global_rotate(get_parent().global_transform.basis.y, y)
	rotate_object_local(Vector3.RIGHT, x)


func limit_axes() -> void:
	var final_transform := transform * _initial_transform.affine_inverse()
	var euler_rotation := final_transform.basis.get_euler()
	euler_rotation = Vector3(rad2deg(euler_rotation.x),
							rad2deg(euler_rotation.y),
							rad2deg(euler_rotation.z)
							)
	
	if euler_rotation.y > max_yaw:
		if not limit_yaw:
			get_parent().global_rotate(get_parent().global_transform.basis.y, deg2rad(euler_rotation.y - max_yaw))
		
		global_rotate(get_parent().global_transform.basis.y, deg2rad(max_yaw - euler_rotation.y))
		
	elif euler_rotation.y < min_yaw:
		if not limit_yaw:
			get_parent().global_rotate(get_parent().global_transform.basis.y, deg2rad(euler_rotation.y - min_yaw))
		
		global_rotate(get_parent().global_transform.basis.y, deg2rad(min_yaw - euler_rotation.y))

	if euler_rotation.x > max_pitch:
		if not limit_pitch:
			get_parent().global_rotate(global_transform.basis.x, deg2rad(euler_rotation.x - max_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(max_pitch - euler_rotation.x))
		
	elif euler_rotation.x < min_pitch:
		if not limit_pitch:
			get_parent().global_rotate(global_transform.basis.x, deg2rad(euler_rotation.x - min_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(min_pitch - euler_rotation.x))
	
	


func turn_to_vector(position: Vector3):
	_target_transform = global_transform.looking_at(position, get_parent().global_transform.basis.y)
	set_process(true)


func _process(delta):
	_target_transform.origin = global_transform.origin
	global_transform = global_transform.interpolate_with(_target_transform, turn_speed * delta)

	if global_transform.basis.tdotz(_target_transform.basis.z) >= 0.99:
		set_process(false)


func _physics_process(delta):
	limit_axes()
