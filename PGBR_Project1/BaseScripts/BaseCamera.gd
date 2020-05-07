class_name BaseCamera
extends Camera


var move_speed := 20.0		# this is the speed when the camera is a spectator

var _player_node
var _pivot_node						# the node the camera will move to
var _current_scene
var _interpolate_speed := 0.1		# used whenever there is any interpolation done
var _lock_onto_player := false


func _ready():
	_current_scene = get_tree().get__current_scene()
	
	# this is an easy way to assign a player to a camera
	# just make the player the parent, and the camera will reassign itself
	if get_parent() != _current_scene:
		_player_node = get_parent()
		_player_node.remove_child(self)
		_current_scene.add_child(self)


func set_player(node):
	_player_node = node
	_pivot_node = node.get_node("CameraPivot")


func _process(delta):
	if _lock_onto_player:
		# locking on just means copying the position exactly
		global_transform.origin = _pivot_node.global_transform.origin
	
	else:
		# this will mvoe the camera towards the player node
		global_transform.origin += _pivot_node.linear_velocity * delta
		global_transform.origin = global_transform.origin.linear_interpolate(_pivot_node.global_transform.origin, _interpolate_speed)
		
		if global_transform.origin.distance_to(_pivot_node.global_transform.origin) < 0.5:
			# if the camera and the player are close enough, then just lock onto the player
			_lock_onto_player = true
