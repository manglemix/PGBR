class_name BaseCamera
extends Camera


enum Viewpoint {FPS, TPS}	# First Person, Third Person

export(Viewpoint) var current_viewpoint := Viewpoint.FPS setget set_viewpoint
export var _player_path: NodePath
export var move_speed := 20.0			# this is the speed when the camera is a spectator
export var mouse_sensitivity = 0.001
export var invert_y := false

var linear_velocity := Vector3.ZERO
var screen_centre: Vector2
var accept_user_input := true setget set_user_input

var _player_node					# the node from which the pivot will be used
var _pivot_node						# the node the camera will pivot around
var _target_node: Spatial			# the child of the pivot node; the node the camera will move to
var _current_scene
var _raycast := RayCast.new()		# private raycast node
var _old_player = null				# the last node which was a player


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	screen_centre = get_viewport().size / 2
	add_child(_raycast)
	_raycast.enabled = true
	
	_current_scene = get_tree().get_current_scene()
	
	set_player(get_node_or_null(_player_path))


func set_user_input(value: bool):
	accept_user_input = value
	set_process_input(value)


func set_player(node):
	# makes the camera follow the node given, as long as that node has a child called CameraPivot,
	# which should also have a child called CameraTarget
	if is_instance_valid(_player_node):
		_old_player = _player_node
		_player_node.disconnect("died", self, "handle_death")
	
	_raycast.clear_exceptions()
	
	_player_node = node
	
	if is_instance_valid(_player_node) and _player_node.has_head:
		_pivot_node = _player_node.get_node("Head")
		_target_node = _pivot_node.get_node("CameraTarget")
		assert(is_instance_valid(_target_node))
		
		set_viewpoint(current_viewpoint)
		_player_node.connect("died", self, "handle_death")
		_raycast.add_exception(_player_node)
		_current_scene.player = _player_node
	
	else:
		_pivot_node = null
		_target_node = null


func handle_death(code):
	if code == GlobalEnums.Killcodes.KILLED:
		# some code if the player was killed normally
		pass
	
	elif code == GlobalEnums.Killcodes.SUICIDE:
		# some code if the player killed themselves
		pass
	
	elif code == GlobalEnums.Killcodes.GLITCHED:
		# some code if the player died in a weird way
		var target := Transform.IDENTITY
		target.origin.y = 10.0
		move_to(target)
		set_player(null)


func set_viewpoint(new_viewpoint: int):
	if not is_instance_valid(_player_node):
		return
	
	current_viewpoint = new_viewpoint
	_target_node.set_transform_index(current_viewpoint)


func move_to(target_transform: Transform):
	# replaces the current active camera with an AnimatedCamera which moves to the Transform given
	# keep in mind this causes the camera to leave the previous player
	var camera := preload("res://AnimatedCamera.tscn").instance()
	_current_scene.add_child(camera)
	
	camera.global_transform = global_transform
	camera.interpolated = true
	camera.target_transform = target_transform
	camera.current = true
	camera.connect("reached_target", self, "set_user_input", [true])
	camera.connect("reached_target", self, "set_current", [true])
	camera.connect("reached_target", camera, "queue_free")
	
	set_player(null)
	global_transform = target_transform
	linear_velocity *= 0.0
	set_user_input(false)


func project_raycast(screen_point:=screen_centre, distance:=far):
	_raycast.cast_to = _raycast.to_local(project_position(screen_point, distance))


func get_collider():
	return _raycast.get_collider()


func get_collision_point() -> Vector3:
	return _raycast.get_collision_point()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("spectate"):
		if is_instance_valid(_old_player):
			set_player(_old_player)
			_old_player = null
			
		else:
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
			current_viewpoint = _target_node.transform_index
	
	else:
		# this is for when the camera has no player to follow
		# it is basically a free moving camera
		if event is InputEventMouseMotion:
			if invert_y:
				event.relative.y *= -1
			
			global_rotate(Vector3.UP, - event.relative.x * mouse_sensitivity)
			if abs(rotation.x - event.relative.y * mouse_sensitivity) < PI / 2:
				rotate_object_local(Vector3.RIGHT, - event.relative.y * mouse_sensitivity)


func _process(delta):
	if is_instance_valid(_player_node):
		# save the player's linear_velocity for when the player dies
		linear_velocity = _player_node.linear_velocity
		global_transform = _target_node.global_transform
		
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
					speed = _player_node.Speeds.SPRINT
				elif Input.is_action_pressed("crouch"):
					# TODO add crouch mechanic
					speed = _player_node.Speeds.WALK
				else:
					speed = _player_node.Speeds.RUN
				
				_player_node.move_to_vector(movement_vector, speed)
			
			if Input.is_action_pressed("shoot"):
				# casts the raycast node towards the crosshair (centre of screen)
				project_raycast()
				var target := get_collision_point()
				_player_node.global_turn_to_vector(target)
				_player_node.aim_guns(target)
				_player_node.shoot_guns()
	
	elif accept_user_input:
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
	
		global_transform.origin += linear_velocity * delta
		# this slows down the camera
		linear_velocity *= 0.97
