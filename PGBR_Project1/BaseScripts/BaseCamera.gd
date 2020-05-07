class_name BaseCamera
extends Camera


var move_speed := 20.0		# this is the speed when the camera is a spectator
var linear_velocity := Vector3.ZERO

var _player_node
var _pivot_node						# the node the camera will move to
var _current_scene
var _interpolate_speed := 0.1		# used whenever there is any interpolation done
var _lock_onto_player := false


func _ready():
	_current_scene = get_tree().get_current_scene()
	
	get_parent().connect("ready", self, "_set_player_from_parent")


func set_player(node):
	_player_node = node
	_pivot_node = node.get_node("CameraPivot")
	_lock_onto_player = false


func _set_player_from_parent():
	_player_node = get_parent()
	_pivot_node = _player_node.get_node("CameraPivot")
	_lock_onto_player = false


	if is_instance_valid(_player_node):
		if _lock_onto_player:
			# locking on just means copying the position exactly
			global_transform.origin = _pivot_node.global_transform.origin
		
		else:
			# interpolates the camera speed with the player's speed
			linear_velocity = linear_velocity.linear_interpolate(_player_node.linear_velocity, _interpolate_speed)
			# this will mvoe the camera towards the player node
			global_transform.origin += linear_velocity * delta
			
			if global_transform.origin.distance_to(_pivot_node.global_transform.origin) < 0.5:
				# if the camera and the player are close enough, then just lock onto the player
				_lock_onto_player = true
				
	else:
		global_transform.origin += linear_velocity * delta
