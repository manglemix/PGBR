class_name BaseCamera
extends Camera


var move_speed := 20.0		# this is the speed when the camera is a spectator
var linear_velocity := Vector3.ZERO
var mouse_sensitivity = 0.001
var max_pitch := 80.0		# the largest angle by which the camera can look up or down by

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
	get_parent().remove_child(self)
	_pivot_node.add_child(self)
	_lock_onto_player = false


func _set_player_from_parent():
	set_player(get_parent())


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if is_instance_valid(_player_node):
		if event is InputEventMouseMotion:
			_player_node.rotate_object_local(_player_node.global_transform.basis.y, - event.relative.x * mouse_sensitivity)
			rotate_object_local(Vector3.LEFT, event.relative.y * mouse_sensitivity)
			
			if abs(rotation_degrees.x) >= max_pitch:
				rotate_object_local(Vector3.LEFT, - event.relative.y * mouse_sensitivity)
		
		if event.is_action_pressed("jump"):
			_player_node.jump()


func _process(delta):
	if is_instance_valid(_pivot_node):
		# checks if the pivot node is within 5 cm
		_lock_onto_player = global_transform.origin.distance_to(_pivot_node.global_transform.origin) < 0.05
		
		# if the pivot node is too far, interpolate towards it
		if not _lock_onto_player:
			# this will move the camera towards the pivot node
			global_transform = global_transform.interpolate_with(_pivot_node.global_transform, _interpolate_speed)
		
		var movement_vector := Vector3.ZERO
		if Input.is_action_pressed("forward"):
			movement_vector += _player_node.global_transform.basis.z
		
		if Input.is_action_pressed("backward"):
			movement_vector -= _player_node.global_transform.basis.z
		
		if Input.is_action_pressed("right"):
			movement_vector -= _player_node.global_transform.basis.x
		
		if Input.is_action_pressed("left"):
			movement_vector += _player_node.global_transform.basis.x
		
		if is_zero_approx(movement_vector.length_squared()):
			_player_node.stop_moving()
		else:
			_player_node.move_to_vector(movement_vector.normalized())
			
	else:
		global_transform.origin += linear_velocity * delta
