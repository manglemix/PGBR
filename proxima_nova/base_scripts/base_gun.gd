class_name BaseGun
extends Spatial


export var _raycast_path := NodePath("Muzzle")
export(Array, NodePath) var _handle_paths := []
export var clipping_distance := 1000.0 setget set_clipping_distance

var dont_save := ["_player", "_handles", "_raycast"]
var can_fire := true

var _player: Node
var _handles := {}

onready var _raycast := get_node(_raycast_path) as RayCast


func _ready():
	set_clipping_distance(clipping_distance)
	
	assert(not _handle_paths.empty())
	for path in _handle_paths:
		_handles[get_node(path)] = null
	
	if get_parent() is BasePerson:
		get_parent().connect("ready", self, "equip_node", [get_parent(), true])
	
	elif get_parent().owner is BasePerson:
		get_parent().owner.connect("ready", self, "equip_node", [get_parent().owner, true])


func equip_node(node: Node, try_assert:=false) -> bool:
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
	_player.equipment.append(self)
	
	get_parent().remove_child(self)
	_handles.values()[0].get_parent().add_child(self)
	transform = _handles.values()[0].transform
	
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform
	
	return true


func set_clipping_distance(distance: float) -> void:
	if not is_instance_valid(_raycast):
		return
	
	assert(distance > 0)
	clipping_distance = distance
	_raycast.cast_to = _raycast.cast_to.normalized() * distance


func aim_towards(target: Vector3) -> void:
	get_parent().look_at(target, Vector3.UP)
	get_parent().rotate_object_local(Vector3.UP, PI)
	
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform


func get_collider():
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = true
	_raycast.force_raycast_update()
	return _raycast.get_collider()


func shoot() -> void:
	if not can_fire:
		return false
	
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = false
	_raycast.force_raycast_update()
	var node = _raycast.get_collider()
	
	if is_instance_valid(node):
		if node.has_method("damage"):
			node.damage(self)
		
	else:
		_raycast.collide_with_areas = false
		_raycast.collide_with_bodies = true
		_raycast.force_raycast_update()
		var node2 = _raycast.get_collider()
		
		if is_instance_valid(node2) and node2.has_method("damage"):
			node2.damage(self)
	
	Debug.draw_dot(_raycast.get_collision_point(), Color.red)
