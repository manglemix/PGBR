class_name BaseGun
extends Spatial


export var raycast_path := NodePath("Muzzle")
export(Array, NodePath) var handle_paths := []

var _player
var _handles := {}

onready var _raycast := get_node(raycast_path) as RayCast


func _ready():
	set_distance(1000)
	
	assert(not handle_paths.empty())
	for path in handle_paths:
		_handles[get_node(path)] = null
	
	if get_parent() != get_tree().get_current_scene():
		get_parent().connect("ready", self, "equip_node", [get_parent(), true])


func equip_node(node, try_assert:=false) -> bool:
	# the try assert is to cause the game to crash if the gun could not be equipped
	# useful if the gun did not get equipped at the start of the level during development
	for handle in _handles:
		var hand = node.borrow_hand()
		
		if not is_instance_valid(hand):
			if try_assert:
				assert(false)
			return false
		
		_handles[handle] = hand
	
	_player = node
	_player.connect("shoot", self, "shoot")
	_player.connect("aim", self, "aim_towards")
	_player.guns.append(self)
	
	get_parent().remove_child(self)
	_handles.values()[0].get_parent().add_child(self)
	transform = _handles.values()[0].transform
	
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform
	
	return true


func set_distance(distance: float):
	assert(distance > 0)
	_raycast.cast_to = _raycast.cast_to.normalized() * distance


func aim_towards(target: Vector3):
	get_parent().look_at(target, Vector3.UP)
	get_parent().rotate_object_local(Vector3.UP, PI)
	
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform


func get_collider():
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = true
	_raycast.force_raycast_update()
	return _raycast.get_collider()


func shoot():
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = false
	_raycast.force_raycast_update()
	var node = _raycast.get_collider()
	
	if is_instance_valid(node):
		print(node)
		if node.has_method("damage"):
			node.damage(self)
		
	else:
		_raycast.collide_with_areas = false
		_raycast.collide_with_bodies = true
		_raycast.force_raycast_update()
		var node2 = _raycast.get_collider()
		
		print(node2)
		if is_instance_valid(node2) and node2.has_method("damage"):
			node2.damage(self)
	
	Debug.draw_dot(_raycast.get_collision_point(), Color.red)
