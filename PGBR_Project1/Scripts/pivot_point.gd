class_name PivotPoint
extends Spatial


export var max_pitch := 70.0
export var min_pitch := - 70.0
export var max_yaw := 45.0
export var min_yaw := -45.0
export var limit_pitch := true
export var limit_yaw := false
export var turn_speed := 6.0

var _target_transform: Transform


func _ready():
	set_process(false)


func axial_rotate(axis: Vector3, angle: float) -> void:
	global_rotate(axis, angle)
	limit_axes()


func biaxial_rotate(x: float, y: float) -> void:
	global_rotate(get_parent().global_transform.basis.y, y)
	global_rotate(global_transform.basis.x, x)
	limit_axes()


func limit_axes() -> void:
	if rotation_degrees.y >= max_yaw:
		if not limit_yaw:
			owner.global_rotate(get_parent().global_transform.basis.y, deg2rad(rotation_degrees.y - max_yaw))
		
		rotation_degrees.y = max_yaw
		
	elif rotation_degrees.y <= min_yaw:
		if not limit_yaw:
			owner.global_rotate(get_parent().global_transform.basis.y, deg2rad(rotation_degrees.y - min_yaw))
		
		rotation_degrees.y = min_yaw

	if rotation_degrees.x >= max_pitch:
		if not limit_pitch:
			owner.global_rotate(global_transform.basis.x, deg2rad(rotation_degrees.x - max_pitch))
		
		rotation_degrees.x = max_pitch
		
	elif rotation_degrees.x <= min_pitch:
		if not limit_pitch:
			owner.global_rotate(global_transform.basis.x, deg2rad(rotation_degrees.x - min_pitch))
		
		rotation_degrees.x = min_pitch


func turn_to_vector(position: Vector3):
	_target_transform = global_transform.looking_at(position, get_parent().global_transform.basis.y)
	set_process(true)


func _process(delta):
	_target_transform.origin = global_transform.origin
	global_transform = global_transform.interpolate_with(_target_transform, turn_speed * delta)
	limit_axes()
	
	if global_transform.basis.tdotz(_target_transform.basis.z) >= 0.99:
		set_process(false)
