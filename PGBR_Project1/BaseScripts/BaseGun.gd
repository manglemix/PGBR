class_name BaseGun
extends RayCast


var arm

var _hand


func _ready():
	set_distance(1000)
	enabled = true
	
	if get_parent() != get_tree().get_current_scene():
		get_parent().connect("ready", self, "_equip_parent")


func equip_node(node) -> bool:
	_hand = node.request_hand()
	
	if is_instance_valid(_hand):
		node.connect("shoot", self, "shoot")
		node.connect("aim", self, "aim_towards")
		
		node.guns.append(self)
		
		get_parent().remove_child(self)
		_hand.add_child(self)
		arm = _hand.get_parent()
		transform = Transform.IDENTITY
		return true
	else:
		return false


func _equip_parent():
	equip_node(get_parent())


func set_distance(distance: float):
	assert(distance > 0)
	cast_to = Vector3.FORWARD * distance


func aim_towards(target: Vector3):
	arm.look_at(target, Vector3.UP)
	_hand.look_at(target, Vector3.UP)


func shoot():
	var node = get_collider()
	
	if is_instance_valid(node) and node.has_method("damage"):
		node.damage(self)
	
	Debug.draw_dot(get_collision_point(), Color.red)
