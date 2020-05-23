# A general purpose node for movement and rotation convenience. User and AI ready
class_name BasePerson
extends KinematicBody


signal shoot				# when emitted, all gun nodes connected to this should shoot
signal died(code)			# may or may not be needed, we'll be watched by the current scene
signal aim(target)			# when emitted, all guns and hands will aim towards the target (a global vector)
signal jumped(strength)		# emitted after the jump function is done

signal health_updated(health)
signal max_health_updated(max_health)
signal stamina_updated(stamina)
signal max_stamina_updated(max_stamina)

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
export var jump_speed := 10.0			# the vertical speed given to the person when they jump
export var turn_speed := 10.0			# used for interpolating turns

export var user_input := false setget set_user_input

export(Array, NodePath) var hand_paths	# an array of paths to nodes which are considered hands

var sprinting := false						# to be read but not modified
var crouching := false setget set_crouch

var health := max_health setget set_health
var stamina := max_stamina setget set_stamina

var movement_vector := Vector3.ZERO			# the top down velocity of the person
var fall_acceleration_factor := 1.0			# multiplied with gravity to get final falling acceleration
var linear_velocity := Vector3.ZERO
var charging_jump := false					# if true, the Person will try to charge up its jump strength
var floor_collision: KinematicCollision		# holds information about the floor collider, null if there is no floor

var hands := {}								# a dict of nodes which were considered hands (from hand_paths), refer to _ready for more info
var guns := []

var _jump_charge_start: int					# the system time in msecs when a jump began to charge
var _jump_charge_target: float				# the target strength of the jump
var _jump_charge_factor := 0.001			# jump strength units per millisecond
var _target_vector: Vector3					# the vector the Person tries to turn to
var _relaxed_time: float					# amount of time the Person has not been sprinting

onready var head := find_node("Head") as PivotPoint
onready var camera := head.get_node("Camera") as Camera
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
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	set_process(value)
	set_process_input(value)


func _ready():
	for path in hand_paths:
		# if the value is false, the hand is free, otherwise the hand is not free
		hands[get_node(path)] = false
	
	assert(is_instance_valid(head))
	assert(is_instance_valid(camera))
	set_user_input(user_input)


func move_to_vector(rel_vec: Vector3, speed:=Speeds.RUN) -> void:
	# moves the node towards the relative vector given
	rel_vec.y = 0.0	# must flatten cause the Person can only turn side to side
	sprinting = false
	if floor_collision:
		assert(speed >= 0 and speed <= 2)
		if speed == Speeds.SPRINT and stamina > 0:
			movement_vector = rel_vec.normalized() * sprint_speed
			sprinting = true
			crouching = false
			_relaxed_time = 0.0
			
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
	rel_vec.y = 0.0	# must flatten cause the Person can only turn side to side
	_target_vector = rel_vec.normalized()


func global_turn_to_vector(position: Vector3) -> void:
	# the same as turn to vector, except it turns the Person to a global position
	turn_to_vector(position - global_transform.origin)


func charge_jump(strength:=1.5) -> void:
	if not charging_jump:
		charging_jump = true
		_jump_charge_start = OS.get_system_time_msecs()
	
	_jump_charge_target = strength


func jump() -> void:
	if floor_collision:
		floor_collision = null
		
		var strength := 1.0
		if charging_jump:
			strength += (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor
		
		linear_velocity.y += jump_speed * strength
		charging_jump = false
		emit_signal("jumped", strength)


func borrow_hand():
	# returns the first free hand, or null if there are no free hands
	for hand in hands:
		if not hands[hand]:
			hands[hand] = true
			return hand


func return_hand(hand):
	# sets the hand given to be free
	hands[hand] = false


func aim_guns(position: Vector3) -> void:
	emit_signal("aim", position)


func shoot_guns() -> void:
	emit_signal("shoot")


func fully_face_target(target: Vector3) -> void:
	# this turns both the Person and the arms towards the global vector given
	global_turn_to_vector(target)
	head.global_turn_to_vector(target)
	aim_guns(target)


func kill(code) -> void:
	# handles the death of the player
	if code == GlobalEnums.Killcodes.KILLED:
		# play death animation
		pass
	
	elif code == GlobalEnums.Killcodes.SUICIDE:
		# play death animation
		pass
	
	elif code == GlobalEnums.Killcodes.GLITCHED:
		# for when the person node dies in some weird way
		pass
	
	emit_signal("died", code)
	queue_free()


func _input(event):
	if event is InputEventMouseMotion:
		if _director.invert_y:
			event.relative.y *= -1
		
		head.biaxial_rotate(event.relative.y * _director.mouse_sensitivity, - event.relative.x * _director.mouse_sensitivity)

	# this alerts the player to charge the jump
	if event.is_action_pressed("jump"):
		charge_jump()

	# once the spacebar is released, and a jump was charging, then the player will jump
	elif event.is_action_released("jump") and charging_jump:
		jump()

	if event.is_action_pressed("crouch"):
		crouching = not crouching
		set_crouch(crouching)

	if event.is_action_pressed("change viewpoint"):
		head.get_node("Camera").increment_transform()

	if event.is_action_pressed("aim"):
		_director.mouse_sensitivity /= 1.5

	elif event.is_action_released("aim"):
		_director.mouse_sensitivity *= 1.5


func _process(delta):
	var direction := Vector3.ZERO
	if Input.is_action_pressed("forward"):
		direction += head.global_transform.basis.z
	
	if Input.is_action_pressed("backward"):
		direction -= head.global_transform.basis.z
	
	if Input.is_action_pressed("right"):
		direction -= head.global_transform.basis.x
	
	if Input.is_action_pressed("left"):
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
	
	if Input.is_action_pressed("shoot") or Input.is_action_pressed("aim"):
		var raycast := _director.camera_raycast(camera) as Dictionary
		var target: Vector3
		
		if raycast.empty():
			target = - camera.global_transform.basis.z * camera.far + camera.global_transform.origin
		else:
			target = raycast["position"]
		
		global_turn_to_vector(target)
		aim_guns(target)
		
		if Input.is_action_pressed("shoot"):
			shoot_guns()


func _physics_process(delta):
	# this will turn the Person towards the target vector
	if _target_vector.is_normalized():
		var turn_axis := global_transform.basis.z.cross(_target_vector).normalized()
		
		if turn_axis.is_normalized():
			var turn_angle := global_transform.basis.z.angle_to(_target_vector)
			global_rotate(turn_axis, turn_angle * turn_speed * delta)
			
			head.global_rotate(turn_axis, - turn_angle * turn_speed * delta)
			
			if turn_angle <= 0.0872:		# this is 5 degrees in radians
				_target_vector = Vector3.ZERO
	
	# this tests if the player is directly on the floor
	floor_collision = move_and_collide(Vector3.DOWN * 0.001, true, true, true)
	
	if not floor_collision:
		floor_collision = move_and_collide(Vector3.DOWN * 0.1, true, true, true)
		if floor_collision:
			global_transform.origin += floor_collision.travel
	
	if floor_collision:
		var tmp_vector := movement_vector
		if not is_zero_approx(tmp_vector.length_squared()):
			# we rotate the movement_vector so that it is along the floor plane
			var axis := Vector3.UP.cross(floor_collision.normal).normalized()
			# usually if the axis is still not normalized, the floor normal is pointing straight up already
			if axis.is_normalized():
				tmp_vector = tmp_vector.rotated(axis, Vector3.UP.angle_to(floor_collision.normal))
			
		# then we interpolate the velocity for smoother movement
		linear_velocity = linear_velocity.linear_interpolate(tmp_vector, acceleration * delta)
		
		# if a jump was charging, and the target strength was surpassed, the person will automatically jump
		if charging_jump and (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor >= _jump_charge_target - 1:
			jump()
	
	else:
		crouching = false
		# cannot charge jump while in the air
		charging_jump = false
		# this is strafing
		linear_velocity += movement_vector * delta
		# this is just gravity
		linear_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * fall_acceleration_factor * delta
	
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP)
	
	Debug.draw_points_from_origin([global_transform.origin, linear_velocity], Color.red, 3)

	if sprinting:
		self.stamina -= delta
	else:
		_relaxed_time += delta
		if _relaxed_time >= stamina_lag:
			self.stamina += delta

	if global_transform.origin.y < -100.0:
		kill(GlobalEnums.Killcodes.GLITCHED)
