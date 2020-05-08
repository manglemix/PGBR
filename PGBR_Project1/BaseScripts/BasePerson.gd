class_name BasePerson
extends KinematicBody


signal shoot		# when emitted, all gun nodes connected to this should shoot
signal died			# may or may not be needed, we'll be watched by the current scene

const SPRINT := 2.0		# these correspond to multiples of move_speed
const RUN := 1.0
const WALK := 0.5

var move_speed := 10.0					# the top down speed of the person
var movement_vector := Vector3.ZERO		# the top down velocity of the person
var jump_speed := 10.0					# the vertical speed given to the person when they jump
var vertical_speed := 0.0				# we separate the vertical speed to make things easier
var fall_acceleration := - 9.8			# the rate at which the vertical speed changes, it is unique to each Person as they may have parachutes
var linear_velocity := Vector3.ZERO
var charging_jump := false
var on_floor: bool

var _jump_charge_start: int
var _jump_charge_target: float
var _jump_charge_factor := 0.001


func move_to_vector(vector: Vector3, movement_style:=RUN):
	if is_on_floor():
		assert(vector.is_normalized())
		assert(is_zero_approx(vector.y))	# to make sure the vector is only top down
		movement_vector = vector * move_speed


func stop_moving():
	if is_on_floor():
		movement_vector = Vector3.ZERO


func charge_jump(strength:=1.5):
	if not charging_jump:
		charging_jump = true
		_jump_charge_start = OS.get_system_time_msecs()
	
	_jump_charge_target = strength


func jump():
	if is_on_floor():
		print((OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor + 1)
		vertical_speed = jump_speed
		
		if charging_jump:
			vertical_speed += jump_speed * (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor
	
		charging_jump = false


func shoot_guns():
	emit_signal("shoot")


func _process(delta):
	if charging_jump:
		if is_on_floor():
			if (OS.get_system_time_msecs() - _jump_charge_start) * _jump_charge_factor >= _jump_charge_target - 1:
				jump()
		else:
			charging_jump = false


func _physics_process(delta):
	vertical_speed += fall_acceleration * delta
	linear_velocity = movement_vector
	on_floor = test_move(global_transform, Vector3.DOWN * 0.001)
	linear_velocity.y = vertical_speed
	
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP)
	vertical_speed = linear_velocity.y
