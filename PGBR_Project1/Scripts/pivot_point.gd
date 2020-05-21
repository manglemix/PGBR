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

onready var _fallback_node := get_node(fallback_node_path) as Spatial


func _ready():
	set_process(false)


func biaxial_rotate(x: float, y: float) -> void:
	global_rotate(_fallback_node.global_transform.basis.y, y)
	rotate_object_local(Vector3.RIGHT, x)
	limit_axes()


func limit_axes() -> void:
	if rotation_degrees.y > max_yaw:
		if not limit_yaw:
			_fallback_node.global_rotate(_fallback_node.global_transform.basis.y, deg2rad(rotation_degrees.y - max_yaw))
		
		rotation_degrees.y = max_yaw
		
	elif rotation_degrees.y < min_yaw:
		if not limit_yaw:
			_fallback_node.global_rotate(_fallback_node.global_transform.basis.y, deg2rad(rotation_degrees.y - min_yaw))
		
		rotation_degrees.y = min_yaw

	if rotation_degrees.x > max_pitch:
		if not limit_pitch:
			_fallback_node.global_rotate(global_transform.basis.x, deg2rad(rotation_degrees.x - max_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(max_pitch - rotation_degrees.x))
		
	elif rotation_degrees.x < min_pitch:
		if not limit_pitch:
			_fallback_node.global_rotate(global_transform.basis.x, deg2rad(rotation_degrees.x - min_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(min_pitch - rotation_degrees.x))


func turn_to_vector(position: Vector3):
	_target_transform = global_transform.looking_at(position, _fallback_node.global_transform.basis.y)
	set_process(true)


func _process(delta):
	_target_transform.origin = global_transform.origin
	global_transform = global_transform.interpolate_with(_target_transform, turn_speed * delta)

	if global_transform.basis.tdotz(_target_transform.basis.z) >= 0.99:
		set_process(false)


func _physics_process(delta):
	limit_axes()
