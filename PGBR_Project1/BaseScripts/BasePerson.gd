class_name BasePerson
extends KinematicBody


signal shoot		# when emitted, all gun nodes connected to this should shoot
signal died			# may or may not be needed, we'll be watched by the current scene
signal aim(target)	# when emitted, all guns and hands will aim towards the target (a global vector)

enum SPEEDS {WALK, RUN, SPRINT}

export(Array, NodePath) var arm_paths

var sprint_speed := 20.0			# these correspond to speeds, for move_to_vector
var run_speed := 10.0
var walk_speed := 5.0
var strafe_speed := 3.0

var turn_speed := 10.0					# used for interpolating turns (like when turning the head)
var max_head_yaw := 50.0				# the maximum angle the head can turn by on the y axis, both left and right
var max_head_pitch := 60.0
var min_head_pitch := -60.0
var movement_vector := Vector3.ZERO		# the top down velocity of the person
var acceleration := 6					# used for interpolating the Person's speed to the movement_vector
var jump_speed := 10.0					# the vertical speed given to the person when they jump
var fall_acceleration := - 9.8			# the rate at which the vertical speed changes, it is unique to each Person as they may have parachutes
var linear_velocity := Vector3.ZERO
var charging_jump := false				# if true, the Person will try to charge up its jump strength
var on_floor: bool						# if true, this node is on top of a floor. is_on_floor() is only true if the KinematicBody is in the floor
var arms := []							# a list of nodes which were considered arms (from arm_paths)

var _floor_collision: KinematicCollision	# holds information about the floor collider, null if there is no floor
var _jump_charge_start: int					# the system time in msecs when a jump began to charge
var _jump_charge_target: float				# the target strength of the jump
var _jump_charge_factor := 0.001			# jump strength units per millisecond
var _body_target_vector: Vector3			# the vector the body tries to turn to
var _head_target_vector: Vector3			# the vector the head tries to turn to


func _ready():
	for path in arm_paths:
		arms.append(get_node(path))


func move_to_vector(rel_vec: Vector3, speed:=SPEEDS.RUN):
	# moves the node towards the relative vector given
	rel_vec.y = 0.0	# must flatten cause the body can only turn side to side
	
	if on_floor:
		assert(speed > 0 and speed <= 2)
		if speed == SPEEDS.SPRINT:
			movement_vector = rel_vec.normalized() * sprint_speed
			# decrement stamina
		elif speed == SPEEDS.WALK:
			movement_vector = rel_vec.normalized() * walk_speed
		else:
			movement_vector = rel_vec.normalized() * run_speed
			
	else:
		movement_vector = rel_vec.normalized() * strafe_speed


func turn_to_vector(rel_vec: Vector3):
	# turns the body towards the relative vector given
	rel_vec.y = 0.0	# must flatten cause the body can only turn side to side
	_body_target_vector = rel_vec.normalized()


func global_turn_to_vector(position: Vector3):
	# the same as turn to vector, except it turns the body to a global position
	_body_target_vector = (position - global_transform.origin)
	_body_target_vector.y = 0.0
	_body_target_vector = _head_target_vector.normalized()


func head_to_vector(rel_vec: Vector3):
	# turns the body towards the relative vector given
	# there is no need to flatten the vector as the head can look in any direction
	_head_target_vector = rel_vec.normalized()


func global_head_to_vector(position: Vector3):
	# the same as turn to vector, except it turns the head to a global position
	_head_target_vector = (position - $Head.global_transform.origin)
	_head_target_vector = _head_target_vector.normalized()


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


func request_hand():
	# searches through the available arms, and checks their Hand node
	# if the Hand node has no children, it is considered free and is therefore returned
	var hand
	for arm in arms:
		hand = arm.get_node("Hand")
		if hand.get_child_count() == 0:
			return hand


func shoot_guns():
	emit_signal("shoot")


func aim_towards(target: Vector3):
	# this turns both the body and the arms towards the global vector given
	_body_target_vector = target - global_transform.origin
	_body_target_vector.y = 0.0
	_body_target_vector = _body_target_vector.normalized()
	emit_signal("aim", target)


func _physics_process(delta):
	if _head_target_vector.is_normalized():
		$Head.global_transform = $Head.global_transform.interpolate_with($Head.global_transform.looking_at(_head_target_vector, Vector3.UP), turn_speed * delta)
	
	var head_rotation = $Head.rotation_degrees
	
	# sets the measured rotation in the y axis to be 0 if pointing in the same direction as this node
	# this is because the Head node has to be rotated 180 degrees because the Camera looks at the -z axis
	if head_rotation.y < 0:
		head_rotation.y = - 180 - head_rotation.y
	else:
		head_rotation.y = 180 - head_rotation.y
	
	# rotates the Person node so that the Head does not rotate past the max_head_yaw
	if head_rotation.y < - max_head_yaw:
		$Head.global_rotate(Vector3.UP, deg2rad(head_rotation.y + max_head_yaw) * turn_speed * delta)
		global_rotate(Vector3.UP, - deg2rad(head_rotation.y + max_head_yaw) * turn_speed * delta)
		
	elif head_rotation.y > max_head_yaw:
		$Head.global_rotate(Vector3.UP, deg2rad(head_rotation.y - max_head_yaw) * turn_speed * delta)
		global_rotate(Vector3.UP, - deg2rad(head_rotation.y - max_head_yaw) * turn_speed * delta)
	
	if head_rotation.x < min_head_pitch:
		$Head.rotation_degrees.x = min_head_pitch
	
	elif head_rotation.x > max_head_pitch:
		$Head.rotation_degrees.x = max_head_pitch
	
	if _body_target_vector.is_normalized():
		var turn_axis := global_transform.basis.z.cross(_body_target_vector).normalized()
		
		if turn_axis.is_normalized():
			var turn_angle := global_transform.basis.z.angle_to(_body_target_vector)
			global_rotate(turn_axis, turn_angle * turn_speed * delta)
			$Head.global_rotate(turn_axis, - turn_angle * turn_speed * delta)
			
		Debug.draw_points_from_origin([global_transform.origin, global_transform.basis.z], Color.blue, 3)
		Debug.draw_points_from_origin([global_transform.origin, _body_target_vector], Color.yellow, 3)
	
	
	_floor_collision = move_and_collide(Vector3.DOWN * 0.001, true, true, true)
	on_floor = is_instance_valid(_floor_collision)
	
	if on_floor:
		if not is_zero_approx(movement_vector.length_squared()):
			# we rotate the movement_vector so that it is along the floor plane
			var axis := Vector3.UP.cross(_floor_collision.normal).normalized()
			# usually if the axis is still not normalized, the floor normal is pointing straight up already
			if axis.is_normalized():
				movement_vector = movement_vector.rotated(axis, Vector3.UP.angle_to(_floor_collision.normal))
			
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
	Debug.draw_points_from_origin([global_transform.origin, linear_velocity], Color.red, 3)
