class_name Animator
extends AnimationTree


export var interpolation := 4.5

var _strafe_factor: float
var _interp_speed: float


func ferp(value: float, target: float, t:=_interp_speed) -> float:
	# float interpolation
	return value + (target - value) * t


func set_parameter(name: String, value: float, value_name:="blend_amount") -> void:
	set("parameters/" + name + "/" + value_name, value)


func get_parameter(name: String, value_name:="blend_amount") -> float:
	return get("parameters/" + name + "/" + value_name)


func ferp_parameter(name: String, target: float, value_name:="blend_amount") -> void:
	set_parameter(name, ferp(get_parameter(name, value_name), target), value_name)


func _process(delta):
	_interp_speed = interpolation * delta
	
	if get_parent().on_floor:
		var local_vector := get_parent().global_transform.basis.xform_inv(get_parent().movement_vector).normalized() as Vector3
		ferp_parameter("falling", 0)
		
		if get_parent().crouching:
			ferp_parameter("stand v crouch", 1)
			
			if get_parent().movement_vector.length() > 0:
				ferp_parameter("crouch idle", 1)
				ferp_parameter("crouch strafe", local_vector.x)
				
				if local_vector.z > 0:
					ferp_parameter("crouch forward", 0)
				
				else:
					ferp_parameter("crouch forward", 1)
			
			else:
				ferp_parameter("crouch idle", 0)
		
		else:
			ferp_parameter("stand v crouch", 0)
			
			if get_parent().movement_vector.length() > 0:
				ferp_parameter("stand idle", 1)
			
				if get_parent().sprinting:
					ferp_parameter("run v sprint", 1)
					ferp_parameter("sprint strafe", local_vector.x)
						
					if local_vector.z > 0:
						ferp_parameter("sprint forward", 0)
					
					else:
						ferp_parameter("sprint forward", 1)
				
				else:
					ferp_parameter("run v sprint", 0)
					ferp_parameter("run strafe", local_vector.x)
						
					if local_vector.z > 0:
						ferp_parameter("run forward", 0)
					
					else:
						ferp_parameter("run forward", 1)
			
			else:
				ferp_parameter("stand idle", 0)
		
	else:
		ferp_parameter("falling", 1)
