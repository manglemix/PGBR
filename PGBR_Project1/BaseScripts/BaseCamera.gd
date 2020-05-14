class_name BaseCamera
extends Camera


enum VIEWPOINT {FPS, TPS}	# First Person, Third Person
enum KILLCODE {KILLED, SUICIDE, GLITCHED}		# Same as KILLCODE in Person

export(VIEWPOINT) var current_viewpoint := VIEWPOINT.FPS setget set_viewpoint

var move_speed := 20.0			# this is the speed when the camera is a spectator
var linear_velocity := Vector3.ZERO
var mouse_sensitivity = 0.001
var invert_y := false
var screen_centre: Vector2
var accept_user_input := true setget set_user_input

var _player_node					# the node from which the pivot will be used
var _pivot_node						# the node the camera will pivot around
var _target_node: Spatial			# the child of the pivot node; the node the camera will move to
var _current_scene
var _interpolate_speed := 0.1			# used whenever there is any interpolation done
var _interpolate_to_player := false		# if true, the camera will move to the target node
var _raycast := RayCast.new()
var _old_player = null


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	screen_centre = get_viewport().size / 2
	add_child(_raycast)
	_raycast.enabled = true
	
	_current_scene = get_tree().get_current_scene()
	
	# if the parent to this camera is no the current scene root node
	# then the camera will try to follow that node when that node is ready
	if get_parent() != _current_scene:
		get_parent().connect("ready", self, "_set_player_from_parent")


func set_user_input(value: bool):
	accept_user_input = value
	set_process_input(value)


func set_player(node):
	# makes the camera follow the node given, as long as that node has a child called CameraPivot,
	# which should also have a child called CameraTarget
	if is_instance_valid(_player_node):
		_player_node.disconnect("died", self, "handle_death")
	
	_raycast.clear_exceptions()
	
	if not is_instance_valid(node):
		clear_player()
		return
	
	_player_node = node
	
	_player_node.connect("died", self, "handle_death")
	
	_pivot_node = _player_node.get_node("Head")
	_target_node = _pivot_node.get_node("CameraTarget")
	set_viewpoint(current_viewpoint)
	
	_raycast.add_exception(_player_node)

	get_parent().remove_child(self)
	_pivot_node.add_child(self)
	
	if node != _current_scene:
		_current_scene.player = node


func clear_player():
	if is_instance_valid(_player_node) and "linear_velocity" in _player_node:
		linear_velocity = _player_node.linear_velocity
	
	_player_node = null
	_pivot_node = null
	_target_node = null
	
	get_parent().remove_child(self)
	_current_scene.add_child(self)


func handle_death(code):
	if code == KILLCODE.KILLED:
		# some code if the player was killed normally
		transform = global_transform
	
	elif code == KILLCODE.SUICIDE:
		# some code if the player killed themselves
		transform = global_transform
	
	elif code == KILLCODE.GLITCHED:
		# some code if the player died in a weird way
		var camera := preload("res://AnimatedCamera.tscn").instance()
		_current_scene.add_child(camera)
		camera.global_transform = global_transform
		
		clear_player()
		linear_velocity *= 0
		
		global_transform = Transform.IDENTITY
		global_transform.origin.y = 10
		
		camera.interpolated = true
		camera.target_transform = global_transform
		camera.current = true
		
		camera.connect("reached_target", self, "make_current_camera")
		camera.connect("reached_target", camera, "queue_free")
		set_process_input(false)
		return
	
	clear_player()


func set_viewpoint(new_viewpoint: int):
	if not is_instance_valid(_player_node):
		return
	
	current_viewpoint = new_viewpoint
	_target_node.set_transform_index(current_viewpoint)


func _set_player_from_parent():
	set_player(get_parent())


func project_raycast(screen_point:=screen_centre, distance:=far):
	_raycast.cast_to = _raycast.to_local(project_position(screen_point, distance))


func get_collider():
	return _raycast.get_collider()


func get_collision_point() -> Vector3:
	return _raycast.get_collision_point()


func make_current_camera():
	set_user_input(true)
	current = true


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("spectate"):
		if is_instance_valid(_old_player):
			set_player(_old_player)
			_old_player = null
		else:
			transform = global_transform
			_old_player = _player_node
			set_player(null)
	
	if is_instance_valid(_player_node):
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			_pivot_node.global_rotate(_player_node.global_transform.basis.y, - event.relative.x * mouse_sensitivity)
			_pivot_node.rotate_object_local(Vector3.RIGHT, - event.relative.y * mouse_sensitivity)
		
		# this alerts the player to charge the jump
		if event.is_action_pressed("jump"):
			_player_node.charge_jump()
		
		# once the spacebar is released, and a jump was charging, then the player will jump
		elif event.is_action_released("jump") and _player_node.charging_jump:
			_player_node.jump()
		
		if event.is_action_pressed("change viewpoint"):
			_target_node.increment_transform()
	
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
		
		if accept_user_input:
			var movement_vector := Vector3.ZERO
			if Input.is_action_pressed("forward"):
				movement_vector -= _pivot_node.global_transform.basis.z
			
			if Input.is_action_pressed("backward"):
				movement_vector += _pivot_node.global_transform.basis.z
			
			if Input.is_action_pressed("right"):
				movement_vector += _pivot_node.global_transform.basis.x
			
			if Input.is_action_pressed("left"):
				movement_vector -= _pivot_node.global_transform.basis.x
			
			if not is_zero_approx(movement_vector.length_squared()):
				# To make the player look less wonky while moving, the body of the player is turned to face-
				# the head direction when moving
				var direction = - _pivot_node.global_transform.basis.z
				_player_node.turn_to_vector(direction)
				
				var speed: float
				if Input.is_action_pressed("sprint"):
					speed = _player_node.SPEEDS.SPRINT
				elif Input.is_action_pressed("crouch"):
					# TODO add crouch mechanic
					speed = _player_node.SPEEDS.WALK
				else:
					speed = _player_node.SPEEDS.RUN
				
				_player_node.move_to_vector(movement_vector, speed)
			
			if Input.is_action_pressed("shoot"):
				# casts the raycast node towards the crosshair (centre of screen)
				project_raycast()
				var target := get_collision_point()
				_player_node.global_turn_to_vector(target)
				_player_node.aim_guns(target)
				_player_node.shoot_guns()
			
	else:
		# this is for when the camera has no player to follow
		# it is basically a free moving camera
		global_transform.origin += linear_velocity * delta
		
		if accept_user_input:
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
