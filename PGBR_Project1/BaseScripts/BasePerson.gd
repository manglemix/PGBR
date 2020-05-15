class_name BasePerson
extends KinematicBody


signal shoot		    # when emitted, all gun nodes connected to this should shoot
signal died(code)		# may or may not be needed, we'll be watched by the current scene
signal aim(target)	# when emitted, all guns and hands will aim towards the target (a global vector)

signal health_updated(health)
signal max_health_updated(max_health)
signal stamina_updated(stamina)
signal max_stamina_updated(max_stamina)

enum Speeds {WALK, RUN, SPRINT}
enum Killcodes {KILLED, SUICIDE, GLITCHED}

export(Array, NodePath) var arm_paths

export var sprint_speed := 10.0			# these correspond to speeds, for move_to_vector
export var run_speed := 5.0
export var walk_speed := 2.5
export var strafe_speed := 3.0

export var max_health := 100.0 setget set_max_health
export var max_stamina := 3.0 setget set_max_stamina# seconds
export var stamina_regen := 0.5 # seconds
export var health_regen := 1.0
export var stamina_lag := 2.0 	# the time before the stamina begins regenerating

export var acceleration := 6	# used for interpolating the Person's speed to the movement_vector
export var jump_speed := 10.0						# the vertical speed given to the person when they jump
export var turn_speed := 10.0						# used for interpolating turns

var sprinting := false
var crouching := false

var health := max_health setget set_health
var stamina := max_stamina setget set_stamina

var movement_vector := Vector3.ZERO			# the top down velocity of the person
var fall_acceleration := - 9.8				# the rate at which the vertical speed changes, it is unique to each Person as they may have parachutes
var linear_velocity := Vector3.ZERO
var charging_jump := false					# if true, the Person will try to charge up its jump strength
var on_floor: bool							# if true, this node is on top of a floor. is_on_floor() is only true if the KinematicBody is in the floor
var arms := []								# a list of nodes which were considered arms (from arm_paths)
var guns := []

var _floor_collision: KinematicCollision	# holds information about the floor collider, null if there is no floor
var _jump_charge_start: int					# the system time in msecs when a jump began to charge
var _jump_charge_target: float				# the target strength of the jump
var _jump_charge_factor := 0.001			# jump strength units per millisecond
var _body_target_vector: Vector3			# the vector the body tries to turn to
var _relaxed_time: float					# amount of time the Person has not been sprinting


# getters and setters
func set_health(new_val: float):
	health = clamp(new_val, 0, max_health)
	emit_signal("health_updated", health)


func set_max_health(new_val: float):
	assert(max_health > 0)
	max_health = new_val
	emit_signal("max_health_updated", max_health)


func set_stamina(new_val: float):
	stamina = clamp(new_val, 0, max_stamina)
	emit_signal("stamina_updated", stamina)


func set_max_stamina(new_val: float):
	assert(max_stamina > 0)
	max_stamina = new_val
	emit_signal("max_stamina_updated", max_stamina)


func _ready():
	for path in arm_paths:
		arms.append(get_node(path))


func move_to_vector(rel_vec: Vector3, speed:=Speeds.RUN):
	# moves the node towards the relative vector given
	rel_vec.y = 0.0	# must flatten cause the body can only turn side to side
	
	sprinting = false
	if on_floor:
		assert(speed >= 0 and speed <= 2)
		if speed == Speeds.SPRINT and stamina > 0:
			movement_vector = rel_vec.normalized() * sprint_speed
			sprinting = true
			_relaxed_time = 0.0
			
		elif speed == Speeds.WALK:
			movement_vector = rel_vec.normalized() * walk_speed
			
		else:
			movement_vector = rel_vec.normalized() * run_speed
		
	else:
		movement_vector = rel_vec.normalized() * strafe_speed


func global_move_to_vector(position: Vector3, speed:=Speeds.RUN):
	move_to_vector(position - global_transform.origin, speed)


func turn_to_vector(rel_vec: Vector3):
	# turns the body towards the relative vector given
	rel_vec.y = 0.0	# must flatten cause the body can only turn side to side
	_body_target_vector = rel_vec.normalized()


func global_turn_to_vector(position: Vector3):
	# the same as turn to vector, except it turns the body to a global position
	turn_to_vector(position - global_transform.origin)


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


func aim_guns(position: Vector3):
	emit_signal("aim", position)


func fully_face_target(target: Vector3):
	# this turns both the body and the arms towards the global vector given
	global_turn_to_vector(target)
	aim_guns(target)
	
	var head = get_node_or_null("Head")
	if is_instance_valid(head):
		head.global_head_to_vector(target)


func kill(code):
	# handles the death of the player
	if code == Killcodes.KILLED:
		# play death animation
		pass
	
	elif code == Killcodes.SUICIDE:
		# play death animation
		pass
	
	elif code == Killcodes.GLITCHED:
		# for when the person node dies in some weird way
		pass
	
	emit_signal("died", code)
	queue_free()


func _physics_process(delta):
	if _body_target_vector.is_normalized():
		var turn_axis := global_transform.basis.z.cross(_body_target_vector).normalized()
		
		if turn_axis.is_normalized():
			var turn_angle := global_transform.basis.z.angle_to(_body_target_vector)
			global_rotate(turn_axis, turn_angle * turn_speed * delta)
			$Head.global_rotate(turn_axis, - turn_angle * turn_speed * delta)
			
			if turn_angle <= 0.0872:		# this is 5 degrees in radians
				_body_target_vector *= 0.0
	
	
	_floor_collision = move_and_collide(Vector3.DOWN * 0.001, true, true, true)
	on_floor = is_instance_valid(_floor_collision)
	
	if not on_floor:
		_floor_collision = move_and_collide(Vector3.DOWN * 0.1, true, true, true)
		on_floor = is_instance_valid(_floor_collision)
		if on_floor:
			global_transform.origin += _floor_collision.travel
	
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
	
	if global_transform.origin.y < -100.0:
		kill(Killcodes.GLITCHED)
	
	Debug.draw_points_from_origin([global_transform.origin, linear_velocity], Color.red, 3)

	if sprinting:
		self.stamina -= delta
	else:
		_relaxed_time += delta
		if _relaxed_time >= stamina_lag:
			self.stamina += delta


func _on_SprintTimer_timeout():
	sprinting = false
