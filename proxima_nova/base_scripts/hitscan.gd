class_name Hitscan
extends RayCast


signal shooting		# emitted before a shot is checked and fired
signal shot			# emitted when a shot is fired

export var clipping_distance := 1000.0 setget set_clipping_distance
export var semi_auto := true

var can_fire := true
var dont_save := ["_director"]

var _already_shot := false
var _director: Director


func _ready():
	_director = get_tree().get_current_scene()
	set_process(false)
	set_process_input(false)
	set_clipping_distance(clipping_distance)
	if get_parent() is Equippable:
		get_parent().connect("equipped", self, "connect_player")
	
	elif get_parent() is BasePerson:
		connect_player(get_parent())
	
	elif get_parent().owner is BasePerson:
		connect_player(get_parent().owner)


func connect_player(player: BasePerson) -> void:
	set_process(true)
	set_process_input(false)


func set_clipping_distance(distance: float) -> void:
	assert(distance > 0)
	clipping_distance = distance
	cast_to = cast_to.normalized() * distance


func aim_towards(target: Vector3) -> void:
	get_parent().look_at(target, Vector3.UP)
	get_parent().rotate_object_local(Vector3.UP, PI)
	get_parent().player.global_turn_to_vector(target)


func collide_all():
	collide_with_areas = true
	collide_with_bodies = true
	force_raycast_update()
	return get_collider()


func shoot() -> bool:
	emit_signal("shooting")
	if not can_fire:
		return false
	
	collide_with_areas = true
	collide_with_bodies = false
	force_raycast_update()
	var node = get_collider()
	
	if is_instance_valid(node):
		if node.has_method("damage"):
			node.damage(self)
		
	else:
		collide_with_areas = false
		collide_with_bodies = true
		force_raycast_update()
		var node2 = get_collider()
		
		if is_instance_valid(node2) and node2.has_method("damage"):
			node2.damage(self)
	
	Debug.draw_dot(get_collision_point(), Color.red)
	emit_signal("shot")
	return true


func _process(_delta):
	if Input.is_action_pressed("aim") or Input.is_action_pressed("shoot"):
		var raycast := _director.current_camera_raycast()
		if "position" in raycast:
			aim_towards(raycast["position"])
		else:
			var camera := get_viewport().get_camera()
			aim_towards(- camera.global_transform.basis.z * camera.far + camera.global_transform.origin)
		
		if Input.is_action_pressed("shoot") and not _already_shot:
			_already_shot = true
			shoot()
	
	if Input.is_action_just_released("shoot"):
		_already_shot = false
