class_name BaseCamera
extends Camera


var move_speed := 20.0		# this is the speed when the camera is a spectator
var linear_velocity := Vector3.ZERO
var mouse_sensitivity = 0.001
var max_pitch := 80.0		# the largest angle by which the camera can look up
var min_pitch := - 80.0		# the largest angle by which the camera can look down
var invert_y := false

var _player_node
var _pivot_node						# the node the camera will pivot around
var _target_node					# the node the camera ill move to
var _current_scene
var _interpolate_speed := 0.1		# used whenever there is any interpolation done
var _lock_onto_player := false


func _ready():
	_current_scene = get_tree().get_current_scene()
	
	# if the parent to this camera is no the current scene root node
	# then the camera will try to follow that node when that node is ready
	if get_parent() != _current_scene:
		get_parent().connect("ready", self, "_set_player_from_parent")


func set_player(node):
	# makes the camera follow the node given, as long as that node has a child called CameraPivot,
	# which should also have a child called CameraTarget
	_player_node = node
	_pivot_node = node.get_node("CameraPivot")
	_target_node = _pivot_node.get_node("CameraTarget")
	assert(is_instance_valid(_target_node))
	
	get_parent().remove_child(self)
	_target_node.add_child(self)
	_lock_onto_player = false


func _set_player_from_parent():
	set_player(get_parent())


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if is_instance_valid(_player_node):
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			_player_node.rotate_object_local(Vector3.UP, - event.relative.x * mouse_sensitivity)
			_pivot_node.rotate_object_local(Vector3.RIGHT, event.relative.y * mouse_sensitivity)
			
			# this undoes the pitch rotation if it goes past the limits given
			if _pivot_node.rotation_degrees.x >= max_pitch or _pivot_node.rotation_degrees.x <= min_pitch:
				_pivot_node.rotate_object_local(Vector3.RIGHT, - event.relative.y * mouse_sensitivity)
		
		if event.is_action_pressed("jump"):
			_player_node.charge_jump()
		
		elif event.is_action_released("jump") and _player_node.charging_jump:
			_player_node.jump()
	
	else:
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			global_rotate(Vector3.UP, - event.relative.x * mouse_sensitivity)
			rotate_object_local(Vector3.LEFT, event.relative.y * mouse_sensitivity)


func _process(delta):
	if is_instance_valid(_player_node):
		# checks if the pivot node is within 5 cm
		_lock_onto_player = global_transform.origin.distance_to(_target_node.global_transform.origin) < 0.05
		
		# if the pivot node is too far, interpolate towards it
		if not _lock_onto_player:
			# this will move the camera towards the pivot node
			global_transform = global_transform.interpolate_with(_target_node.global_transform, _interpolate_speed)
		
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
		
		if Input.is_action_pressed("forward"):
			linear_velocity -= global_transform.basis.z * move_speed * delta
		
		if Input.is_action_pressed("backward"):
			linear_velocity += global_transform.basis.z * move_speed * delta
		
		if Input.is_action_pressed("right"):
			linear_velocity += global_transform.basis.x * move_speed * delta
		
		if Input.is_action_pressed("left"):
			linear_velocity -= global_transform.basis.x * move_speed * delta

		if Input.is_action_pressed("jump"):
			linear_velocity += global_transform.basis.y * move_speed * delta

		if Input.is_action_pressed("crouch"):
			linear_velocity -= global_transform.basis.y * move_speed * delta
		
		# this slows down the camera
		linear_velocity *= 0.97
