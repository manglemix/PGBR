# A general purpose node for movement and rotation convenience. User and AI ready
class_name BasePerson
extends KinematicBody


signal shoot				# when emitted, all gun nodes connected to this should shoot
signal died(code)			# may or may not be needed, we'll be watched by the current scene
signal aim(target)			# when emitted, all equipment and hands will aim towards the target (a global vector)
signal jumped				# emitted when the first jump was done

signal health_updated(health)
signal max_health_updated(max_health)
signal stamina_updated(stamina)
signal max_stamina_updated(max_stamina)

enum Killcodes {KILLED, SUICIDE, GLITCHED}
enum Speeds {WALK, RUN, SPRINT}

export var sprint_speed := 10.0			# these correspond to speeds, for move_to_vector
export var run_speed := 5.0
export var walk_speed := 2.5
export var strafe_speed := 3.0

export var max_health := 100.0 setget set_max_health
export var max_stamina := 3.0 setget set_max_stamina	# unit is seconds
export var stamina_regen := 0.5 		# unit is seconds per second
export var health_regen := 1.0
export var stamina_lag := 2.0 			# the delay before the stamina begins regenerating

export var acceleration := 6.0			# used for interpolating the Person's speed to the movement_vector
export var turn_speed := 10.0			# used for interpolating turns

export var step_height := 0.5
export var max_slope_angle_degrees := 60.0 setget set_max_slope_angle_degrees

export var coyote_time := 0.4				# the time after falling off in which a jump still be done
export var jump_speed := 10.0				# the vertical speed given to the person when they jump
export var max_jump_time := 0.5				# the amount of time in which the first jump has to accelerate
export var first_jump_acceleration := 8.0	# the amount of acceleration during the first jump off the ground
export var max_jetpack_time := 0.5			# the max amount of time the jetpack can thrust for
export var jetpack_acceleration := 10.0
export var jetpack_impulse := 10.0			# the initial push of the jetpack

export(Array, NodePath) var hand_paths	# an array of paths to nodes which are considered hands

var sprinting := false						# to be read but not modified
var crouching := false setget set_crouch
var jumping := false

var health := max_health setget set_health
var stamina := max_stamina setget set_stamina

var user_input := false setget set_user_input
var movement_vector := Vector3.ZERO			# the top down velocity of the person
var fall_acceleration_factor := 1.0			# multiplied with gravity to get final falling acceleration
var linear_velocity := Vector3.ZERO
var floor_collision: KinematicCollision		# holds information about the floor collider, null if there is no floor
var max_slope_angle: float setget set_max_slope_angle
var dont_save := ["hands", "equipment", "_branch", "head", "camera", "_director", "is_ready"]

var is_ready := false						# true once node is ready, used in equippable nodes
var hands := {}								# a dict of nodes which were considered hands (from hand_paths), refer to _ready for more info
var equipment := []
var camera: Camera		# assuming this Person is controlled by the player, they would look through this camera

var _branch: Node
var _jump_charge_duration: float			# time since a jump began charging
var _jump_charge_target: float				# the target strength of the jump
var _jump_charge_factor := 1.0				# jump strength units per second
var _target_vector: Vector3					# the vector the Person tries to turn to
var _relaxed_time: float					# amount of time the Person has not been sprinting
var _time_since_floor: float				# time since contact with the floor
var _jumped: bool
var _jetpack_time := 0.0
var _jump_time := 0.0

onready var head := find_node("Head") as PivotPoint
onready var _director := get_tree().get_current_scene() as Node


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


func set_crouch(value: bool):
	crouching = value


func set_user_input(value: bool):
	set_process(value)
	set_process_input(value)


func set_max_slope_angle_degrees(angle: float):
	max_slope_angle_degrees = angle
	max_slope_angle =  deg2rad(angle)


func set_max_slope_angle(angle: float):
	max_slope_angle = angle
	max_slope_angle_degrees =  rad2deg(angle)


func _ready():
	for path in hand_paths:
		# if the value is false, the hand is free, otherwise the hand is not free
		hands[get_node(path)] = false
	
	if is_instance_valid(head):
		camera = head.find_node("Camera")
	
	is_ready = true
	set_user_input(user_input)


func _enter_tree():
	_branch = get_tree().get_current_scene().get_branch(self)


func move_to_vector(rel_vec: Vector3, speed:=Speeds.RUN) -> void:
	# moves the node towards the relative vector given
	rel_vec.y = 0	# must flatten cause the Person can only turn side to side
	sprinting = false
	if floor_collision:
		assert(speed >= 0 and speed <= 2)
		if speed == Speeds.SPRINT and stamina > 0:
			movement_vector = rel_vec.normalized() * sprint_speed
			sprinting = true
			crouching = false
			_relaxed_time = 0
			
		elif speed == Speeds.WALK or crouching:
			movement_vector = rel_vec.normalized() * walk_speed
			
		else:
			movement_vector = rel_vec.normalized() * run_speed
		
	else:
		movement_vector = rel_vec.normalized() * strafe_speed


func global_move_to_vector(position: Vector3, speed:=Speeds.RUN) -> void:
	move_to_vector(position - global_transform.origin, speed)


func stop_moving() -> void:
	movement_vector = Vector3.ZERO


func turn_to_vector(rel_vec: Vector3) -> void:
	# turns the Person towards the relative vector given
	rel_vec.y = 0	# must flatten cause the Person can only turn side to side
	_target_vector = rel_vec.normalized()


func global_turn_to_vector(position: Vector3) -> void:
	# the same as turn to vector, except it turns the Person to a global position
	turn_to_vector(position - global_transform.origin)


func borrow_hands(count := 1) -> Array:
	# returns the first hands that are free, or an empty list if not enough
	# hands labelled true are occupied
	var reserved := []
	for hand in hands:
		if not hands[hand]:
			reserved.append(hand)
			if reserved.size() == count:
				break
	
	# if we went through the whole list of hands and there still weren';'t enough hands
	if reserved.size() != count:
		return []
	
	# this will set all reserved hands as occupied
	for hand in reserved:
		hands[hand] = true
	
	return reserved


func return_hands(used_hands: Array) -> void:
	# sets the hand given to be free
	for hand in used_hands:
		hands[hand] = false


func aim_guns(position: Vector3) -> void:
	emit_signal("aim", position)


func shoot_guns() -> void:
	emit_signal("shoot")


func fully_face_target(target: Vector3) -> void:
	# this turns both the Person and the arms towards the global vector given
	global_turn_to_vector(target)
	if is_instance_valid(head):
		head.global_turn_to_vector(target)
	aim_guns(target)


func kill(code) -> void:
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


func _integrate_velocity(vector: Vector3, delta: float) -> Vector3:
	# determines how the input vector (representing the direction to move in global space and speed at which to move) affects velocity
	# vector is the input vector, delta is the timestep, and the value returned should be the new velocity
	return linear_velocity.linear_interpolate(vector, acceleration * delta)


func _input(event):
	if event is InputEventMouseMotion:
		if _director.invert_y:
			event.relative.y *= -1
		
		head.biaxial_rotate(event.relative.y * _director.mouse_sensitivity, - event.relative.x * _director.mouse_sensitivity)
	
	# this alerts the player to charge the jump
	if event.is_action_pressed("jump"):
		for pad in _branch.jump_pads:
			if self in pad.get_overlapping_bodies():
				pad.jump(self)
				return
		jumping = true
	
	elif event.is_action_released("jump"):
		jumping = false
	
	if event.is_action_pressed("crouch"):
		crouching = not crouching
		set_crouch(crouching)
	
	if event.is_action_pressed("change viewpoint"):
		camera.increment_transform()


func _process(_delta):
	var direction := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction += head.global_transform.basis.z
	
	if Input.is_action_pressed("move_backward"):
		direction -= head.global_transform.basis.z
	
	if Input.is_action_pressed("move_right"):
		direction -= head.global_transform.basis.x
	
	if Input.is_action_pressed("move_left"):
		direction += head.global_transform.basis.x
	
	if is_zero_approx(direction.length_squared()):
		stop_moving()
		
	else:
		# To make the player look less wonky while moving, the body of the player is turned to face-
		# the head direction when moving
		turn_to_vector(head.global_transform.basis.z)
		
		var speed: float
		if Input.is_action_pressed("sprint"):
			speed = Speeds.SPRINT
		elif Input.is_action_pressed("crouch"):
			# TODO add crouch mechanic
			speed = Speeds.WALK
		else:
			speed = Speeds.RUN
		
		move_to_vector(direction, speed)


func _physics_process(delta):
	# this will turn the Person towards the target vector
	if _target_vector.is_normalized():
		var turn_axis := global_transform.basis.z.cross(_target_vector).normalized()
		
		if turn_axis.is_normalized():
			var turn_angle := global_transform.basis.z.angle_to(_target_vector)
			global_rotate(turn_axis, turn_angle * turn_speed * delta)
			
			if is_instance_valid(head):
				head.global_rotate(turn_axis, - turn_angle * turn_speed * delta)
			
			if turn_angle <= 0.0872:		# this is 5 degrees in radians
				_target_vector = Vector3.ZERO
	
	# this tests if the player is directly on the floor
	floor_collision = move_and_collide(Vector3.DOWN * 0.01, true, true, true)
	if not floor_collision and not jumping:
		# this will snap the player to the floor as long as the player is 10cm off of it
		floor_collision = move_and_collide(Vector3.DOWN * 0.1, true, true, true)
		if floor_collision:
			global_transform.origin += floor_collision.travel
	
	if floor_collision:
		_time_since_floor = 0
		_jetpack_time = 0
		_jump_time = 0
		Debug.draw_points_from_origin([floor_collision.position, floor_collision.normal])
		
		var tmp_vector := movement_vector
		if not is_zero_approx(tmp_vector.length_squared()):
			# we rotate the movement_vector so that it is along the floor plane
			var axis := Vector3.UP.cross(floor_collision.normal).normalized()
			# usually if the axis is still not normalized, the floor normal is pointing straight up already
			if axis.is_normalized():
				var angle := Vector3.UP.angle_to(floor_collision.normal)
				if angle < max_slope_angle:
					tmp_vector = tmp_vector.rotated(axis, angle)
		
		# then we interpolate the velocity for smoother movement
		linear_velocity = _integrate_velocity(tmp_vector, delta)
		
	else:
		_time_since_floor += delta
		crouching = false
		# this is strafing
		linear_velocity += movement_vector * delta
		# this is just gravity
		linear_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * fall_acceleration_factor * delta
	
	if jumping:
		if _jumped:
			# this is the acceleration in the first jump
			if _jump_time < max_jump_time:
				linear_velocity.y += first_jump_acceleration * delta
				_jump_time += delta
			
			else:
				jumping = false
				_jumped = false
		
		# Person can still jump within a small time frame after falling
		# however if the person already has jumped (known if _jump_time is not 0), then this is no longer valid
		elif is_zero_approx(_jump_time) and _time_since_floor <= coyote_time:
			# if falling down, nullify downward speed
			if linear_velocity.y < 0:
				linear_velocity.y = 0
			
			emit_signal("jumped")
			linear_velocity.y = jump_speed
			_jumped = true
		
		else:
			var thrust_vector: Vector3
			if is_zero_approx(movement_vector.length_squared()):
				thrust_vector = global_transform.basis.y
			else:
				global_turn_to_vector(movement_vector)
				# get the vector in between the up vector and the movement vector
				thrust_vector = global_transform.basis.y.linear_interpolate(movement_vector.normalized(), 0.5)
			
			if is_zero_approx(_jetpack_time):
				linear_velocity += thrust_vector * jetpack_impulse
			
			# jetpack acceleration
			if _jetpack_time < max_jetpack_time:
				linear_velocity += thrust_vector * jetpack_acceleration * delta
				_jetpack_time += delta
				
			else:
				jumping = false
	
	else:
		_jumped = false
		
		# if the jetpack was used, and the Person stopped jumping the jetpack can no longer be used
		if not is_zero_approx(_jetpack_time):
			_jetpack_time = max_jetpack_time
	
	Debug.draw_points_from_origin([global_transform.origin, linear_velocity], Color.red, 3)
	
	if sprinting:
		self.stamina -= delta
	else:
		_relaxed_time += delta
		if _relaxed_time >= stamina_lag:
			self.stamina += delta
	
	if global_transform.origin.y < -100.0:
		kill(Killcodes.GLITCHED)
	
	# for walking up steps
	if floor_collision:
		var tmp := global_transform
		# move upward to avoid colliding with the floor
		tmp.origin.y += 0.1
		# check if there is an obstacle ahead
		if test_move(tmp, linear_velocity * delta):
			tmp.origin.y += step_height - 0.1
			# check if there is an obstacle above the next frame position
			if not test_move(tmp, linear_velocity * delta):
				global_transform = tmp
				global_transform.origin += linear_velocity * delta
				# this line moves the Body onto the floor
				var result := move_and_collide(Vector3.DOWN * step_height, true, true, true)
				if is_instance_valid(result):
					global_transform.origin += result.travel
				return
	
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP, false, 4, max_slope_angle)
