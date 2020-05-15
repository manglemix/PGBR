class_name PivotPoint
extends Spatial


export var max_pitch := 70.0
export var min_pitch := - 70.0
export var max_yaw := 45.0
export var min_yaw := -45.0
export var limit_pitch := true
export var limit_yaw := false


func axial_rotate(axis: Vector3, angle: float) -> void:
	global_rotate(axis, angle)
	
	if rotation_degrees.x >= max_pitch or rotation_degrees.x <= min_pitch or rotation_degrees.y >= max_yaw or rotation_degrees.y <= min_yaw:
		global_rotate(axis, - angle)


func biaxial_rotate(x: float, y: float) -> void:
	if rotation_degrees.y + y < max_yaw and rotation_degrees.y + y > min_yaw:
		global_rotate(get_parent().global_transform.basis.y, y)
	
	else:
		if rotation_degrees.y + y >= max_yaw:
			rotation_degrees.y = max_yaw
		else:
			rotation_degrees.y = min_yaw
			
		if not limit_yaw:
			owner.global_rotate(get_parent().global_transform.basis.y, y)
	
	if rotation_degrees.x + x < max_pitch and rotation_degrees.x + x > min_pitch:
		global_rotate(global_transform.basis.x, x)
	
	else:
		if rotation_degrees.x + x >= max_pitch:
			rotation_degrees.x = max_pitch
		else:
			rotation_degrees.x = min_pitch
			
		if not limit_pitch:
			owner.global_rotate(global_transform.basis.x, x)
