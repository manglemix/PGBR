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


func move_towards(vector: Vector3, movement_style:=RUN):
	assert(vector.is_normalized())
	assert(is_zero_approx(vector.y))	# to make sure the vector is only top down
	movement_vector = vector * move_speed


func move_to_node(node, movement_style:=RUN):
	movement_vector = node.global_transform.origin - global_transform.origin
	movement_vector.y = 0.0


func stop_moving():
	movement_vector = Vector3.ZERO


func jump(strength:=1.0):
	# there is a strength parameter to help control the jump height
	# this may be controlled by how long the spacebar is held
	
	if is_on_floor():
		vertical_speed = jump_speed * strength


func shoot_guns():
	emit_signal("shoot")


func _physics_process(delta):
	vertical_speed += fall_acceleration * delta
	linear_velocity = movement_vector
	linear_velocity.y = vertical_speed
	
	linear_velocity = move_and_slide(linear_velocity, Vector3.UP)
	vertical_speed = linear_velocity.y
