class_name Animator
extends AnimationTree


var _strafe_factor: float
var _interp_speed := 3.0


func _process(delta):
	if get_parent().movement_vector.length() > 0 and get_parent().on_floor:
		active = true
		var local_vector := get_parent().global_transform.basis.xform_inv(get_parent().movement_vector) as Vector3
		var strafe_limit := local_vector.normalized().x
		
		_strafe_factor += (strafe_limit - _strafe_factor) * _interp_speed * delta
		set("parameters/Move/blend_amount", _strafe_factor)
		set("parameters/MoveSpeed/scale", local_vector.length() / get_parent().run_speed)
	
	else:
		active = false
