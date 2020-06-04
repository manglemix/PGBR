class_name Animator
extends AnimationTree


export var interpolation := 4.5

var _strafe_factor: float
var _interp_speed: float
var _animation_player: AnimationPlayer
var _delay := 0.0


func _ready():
	_animation_player = get_node(anim_player)
	_animation_player.stop()
	get_parent().connect("jumped", self, "jump")
	active = true


func flerp(value: float, target: float, t:=_interp_speed) -> float:
	# float interpolation
	return value + (target - value) * t


func set_parameter(name: String, value, value_name:="blend_amount") -> void:
	set("parameters/" + name + "/" + value_name, value)


func get_parameter(name: String, value_name:="blend_amount"):
	return get("parameters/" + name + "/" + value_name)


func flerp_parameter(name: String, target: float, value_name:="blend_amount") -> void:
	set_parameter(name, flerp(get_parameter(name, value_name), target), value_name)


func lerp_position(name: String, target: Vector2) -> void:
	set_parameter(name, get_parameter(name, "blend_position").linear_interpolate(target, _interp_speed), "blend_position")


func jump():
	_delay = 0.4
	set("parameters/seek/seek_position", 0)


func _process(delta):
	_interp_speed = interpolation * delta
	
	if _delay > 0:
		_delay -= delta
		flerp_parameter("custom", 1)
		return
	else:
		flerp_parameter("custom", 0)
	
	if get_parent().floor_collision:
		flerp_parameter("falling", 0)
		
		if is_zero_approx(get_parent().movement_vector.length_squared()):
			flerp_parameter("idle", 1)
			
			if get_parent().crouching:
				flerp_parameter("crouch idle", 1)
			else:
				flerp_parameter("crouch idle", 0)
			
		else:
			flerp_parameter("idle", 0)
			var local_vector = get_parent().global_transform.basis.xform_inv(get_parent().movement_vector).normalized()
			local_vector = Vector2(local_vector.x, local_vector.z)
			
			if get_parent().sprinting:
				flerp_parameter("speed", 1)
			elif get_parent().crouching:
				flerp_parameter("speed", -1)
			else:
				flerp_parameter("speed", 0)
			
			lerp_position("crouch", local_vector)
			lerp_position("run", local_vector)
			lerp_position("sprint", local_vector)
		
	else:
		flerp_parameter("idle", 1)
		flerp_parameter("falling", 1)
