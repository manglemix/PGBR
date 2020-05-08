class_name BasePerson
extends KinematicBody


signal shoot		# when emitted, all gun nodes connected to this should shoot
signal died			# may or may not be needed, we'll be watched by the current scene
signal aim

export(Array, NodePath) var arm_paths
export(Array, NodePath) var pivot_paths

var SPRINT := 20.0
var RUN := 10.0
var WALK := 5.0
var AIR := 5.0

var move_speed := 10.0					# the top down speed of the person
var movement_vector := Vector3.ZERO		# the top down velocity of the person
var acceleration := 6
var jump_speed := 10.0					# the vertical speed given to the person when they jump
var fall_acceleration := - 9.8			# the rate at which the vertical speed changes, it is unique to each Person as they may have parachutes
var linear_velocity := Vector3.ZERO
var charging_jump := false				# if true, the Person will try to charge up its jump strength
var on_floor: bool						# if true, the KinematicBody is on top of a floor. is_on_floor() is only true if the KinematicBody is in the floor
var arms := {}

var _floor_collision: KinematicCollision
var _jump_charge_start: int				# the system time in msecs when a jump began to charge
var _jump_charge_target: float			# the target strength of the jump
var _jump_charge_factor := 0.001		# jump strength units per millisecond
var _orientation_vector: Vector3		# the vector the Person is trying to turn towards


func _ready():
	for path in arm_paths:
		arms[get_node(path)] = false

	for path in pivot_paths:
		_pivots.append(get_node(path))


func request_camera_targets(name: String) -> Array:
	var targets := []
	for pivot in _pivots:
		if pivot.name == name:
			for child in pivot.get_children():
				if child is Spatial:
					targets.append(child)
			break
	return targets


func move_to_vector(vector: Vector3, speed:=RUN):
	assert(is_zero_approx(vector.y))	# to make sure the vector is only top down
	
	if not vector.is_normalized():
		push_warning("move_to_vector in " + str(self) + " is not normalized")
		vector = vector.normalized()
	
	if on_floor:
		movement_vector = vector * speed
	else:
		movement_vector += vector * AIR * get_physics_process_delta_time()


func charge_jump(strength:=1.5):
	if not charging_jump:
		charging_jump = true
		_jump_charge_start = OS.get_system_time_msecs()
	
	_jump_charge_target = strength


func jump():
	if on_floor:
		print((OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor + 1)
		linear_velocity.y += jump_speed
		on_floor = false
		
		if charging_jump:
			linear_velocity.y += jump_speed * (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor
	
		charging_jump = false


func shoot_guns():
	emit_signal("shoot")


func aim_guns(target: Vector3):
	emit_signal("aim", target)


func _physics_process(delta):
	_floor_collision = move_and_collide(Vector3.DOWN * 0.001, true, true, true)
	on_floor = is_instance_valid(_floor_collision)
	
	if on_floor:
		# we rotate the movement_vector so that it is along the floor plane
		var axis := Vector3.UP.cross(_floor_collision.normal).normalized()
		# usually if the axis is still not normalized, the floor normal is pointing straight up already
		if axis.is_normalized():
			var angle := Vector3.UP.angle_to(_floor_collision.normal)
			movement_vector = movement_vector.rotated(axis, angle)
		
		# then we interpolate the velocity for smoother movement
		linear_velocity = linear_velocity.linear_interpolate(movement_vector, acceleration * delta)
		
		# if a jump was charging, and the target strength was surpassed, the person will automatically jump
		if charging_jump and (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor >= _jump_charge_target - 1:
			jump()
	
	else:
		# cannot charge jump while in the air
		charging_jump = false
		# this is strafing
		linear_velocity += movement_vector * delta
		# this is just gravity
		linear_velocity.y += fall_acceleration * delta
	
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP)
	movement_vector *= 0.0
	Debug.draw_points([global_transform.origin, global_transform.origin + linear_velocity], Color.red)
