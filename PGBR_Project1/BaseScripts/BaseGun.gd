class_name BaseGun
extends Spatial


export var raycast_path := NodePath("Muzzle")
export(Array, NodePath) var extra_handles := []

var _player
var _handles := {}
var _raycast: RayCast
var _raycast_initial_transform: Transform


func _ready():
	_raycast = get_node(raycast_path)
	_raycast_initial_transform = _raycast.transform
	set_distance(1000)
	
	for path in extra_handles:
		_handles[get_node(path)] = null
	
	if get_parent() != get_tree().get_current_scene():
		get_parent().connect("ready", self, "equip_node", [get_parent(), true])


func equip_node(node, try_assert:=false) -> bool:
	# the try assert is to cause the game to crash if the gun could not be equipped
	# useful if the gun did not get equipped at the start of the level during development
	var main_hand = node.borrow_hand()
	
	if not is_instance_valid(main_hand):
		if try_assert:
			assert(false)
		return false
	
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
	main_hand.add_child(self)
#	_raycast.clear_exceptions()
#	_raycast.add_exception(_player)
	transform = Transform.IDENTITY
	
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform
		_handles[handle].start()
	
	return true


func set_distance(distance: float):
	assert(distance > 0)
	_raycast.cast_to = _raycast.cast_to.normalized() * distance


func aim_towards(target: Vector3):
	_raycast.look_at(target, Vector3.UP)
	get_parent().transform *= _raycast.transform * _raycast_initial_transform.affine_inverse()
	for handle in _handles:
		_handles[handle].global_transform = handle.global_transform


func get_collider():
	return _raycast.get_collider()


func shoot():
	var node = _raycast.get_collider()
	
	if is_instance_valid(node) and node.has_method("damage"):
		node.damage(self)
	
	Debug.draw_dot(_raycast.get_collision_point(), Color.red)
