class_name BaseGun
extends Spatial


var _player

var _raycast: RayCast


func _ready():
	_raycast = get_node("Muzzle")
	set_distance(1000)
	
	if get_parent() != get_tree().get_current_scene():
		get_parent().connect("ready", self, "equip_node", [get_parent()])


func equip_node(node) -> bool:
	var hand = node.borrow_hand()
	
	if is_instance_valid(get_parent()):
		_player = node
		_player.connect("shoot", self, "shoot")
		_player.connect("aim", self, "aim_towards")
		
		_player.guns.append(self)
		
		get_parent().remove_child(self)
		hand.add_child(self)
		transform = Transform.IDENTITY
		return true
	else:
		return false


func set_distance(distance: float):
	assert(distance > 0)
	_raycast.cast_to = _raycast.cast_to.normalized() * distance


func aim_towards(target: Vector3):
	get_parent().look_at(target, Vector3.UP)


func shoot():
	var node = _raycast.get_collider()
	
	if is_instance_valid(node) and node.has_method("damage"):
		node.damage(self)
	
	Debug.draw_dot(_raycast.get_collision_point(), Color.red)
