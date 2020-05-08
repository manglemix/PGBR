class_name BaseCamera
extends Camera


enum PERSPECTIVE {FPS, TPS}

export(PERSPECTIVE) var current_perspective := PERSPECTIVE.FPS

var move_speed := 20.0		# this is the speed when the camera is a spectator
var linear_velocity := Vector3.ZERO
var mouse_sensitivity = 0.001
var max_pitch := 80.0		# the largest angle by which the camera can look up
var min_pitch := - 60.0		# the largest angle by which the camera can look down
var invert_y := false
var screen_centre: Vector2

var _player_node					# the node from which the pivot will be used
var _pivot_node						# the node the camera will pivot around
var _target_node: Spatial			# the child of the pivot node; the node the camera will move to
var _current_scene
var _interpolate_speed := 0.1			# used whenever there is any interpolation done
var _interpolate_to_player := false		# if true, the camera will move to the target node
var _raycast := RayCast.new()


func _ready():
	screen_centre = get_viewport().size / 2
	add_child(_raycast)
	_raycast.enabled = true
	
	_current_scene = get_tree().get_current_scene()
	
	# if the parent to this camera is no the current scene root node
	# then the camera will try to follow that node when that node is ready
	if get_parent() != _current_scene:
		get_parent().connect("ready", self, "_set_player_from_parent")


func set_player(node):
	# makes the camera follow the node given, as long as that node has a child called CameraPivot,
	# which should also have a child called CameraTarget
	_player_node = node
	_pivot_node = _player_node.get_node("Head")
	_target_node = _pivot_node.get_node("CameraTarget")
	change_perspective(current_perspective)
	
	_raycast.clear_exceptions()
	_raycast.add_exception(_player_node)


func change_perspective(new_perspective: int):
	if not is_instance_valid(_player_node):
		return
	
	current_perspective = new_perspective
	_target_node.set_transform_index(current_perspective)
	
	get_parent().remove_child(self)
	_target_node.add_child(self)

func _set_player_from_parent():
	set_player(get_parent())


func project_raycast(screen_point:=screen_centre, distance:=far):
	_raycast.cast_to = _raycast.to_local(project_position(screen_point, distance))


func get_collider():
	return _raycast.get_collider()


func get_collision_point() -> Vector3:
	return _raycast.get_collision_point()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if is_instance_valid(_player_node):
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			_pivot_node.global_rotate(_player_node.global_transform.basis.y, - event.relative.x * mouse_sensitivity)
			_pivot_node.rotate_object_local(Vector3.RIGHT, - event.relative.y * mouse_sensitivity)
			
			# this undoes the pitch rotation if it goes past the limits given
			if _pivot_node.rotation_degrees.x >= max_pitch or _pivot_node.rotation_degrees.x <= min_pitch:
				_pivot_node.rotate_object_local(Vector3.RIGHT, - event.relative.y * mouse_sensitivity)
		
		# this alerts the player to charge the jump
		if event.is_action_pressed("jump"):
			_player_node.charge_jump()
		
		# once the spacebar is released, and a jump was charging, then the player will jump
		elif event.is_action_released("jump") and _player_node.charging_jump:
			_player_node.jump()
	
	else:
		# this is for when the camera has no player to follow
		# it is basically a free moving camera
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			global_rotate(Vector3.UP, - event.relative.x * mouse_sensitivity)
			rotate_object_local(Vector3.LEFT, event.relative.y * mouse_sensitivity)


func _process(delta):
	if is_instance_valid(_player_node):
		# checks if the pivot node is within 5 cm
		_interpolate_to_player = global_transform.origin.distance_to(_target_node.global_transform.origin) > 0.05
		
		# if the pivot node is too far, interpolate towards it
		if _interpolate_to_player:
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
		
		if not is_zero_approx(movement_vector.length_squared()):
			_player_node.move_to_vector(movement_vector.normalized())
		
		if Input.is_action_pressed("shoot"):
			project_raycast()
			var target := get_collision_point()
			Debug.draw_dot(target, Color.red)
			_player_node.aim_guns(target)
			_player_node.shoot_guns()
			
	else:
		# this is for when the camera has no player to follow
		# it is basically a free moving camera
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
