class_name Equippable
extends Spatial


signal equipped(player)
signal unequipped

export var item_name: String
export(Array, NodePath) var _handle_paths := []

var dont_save := ["handles", "player", "_director"]
var handles := {}
var player: BasePerson

onready var _director := get_tree().get_current_scene() as Director


func _ready():
	set_process(false)
	for path in _handle_paths:
		handles[get_node(path)] = null
	
	if get_parent() is BasePerson:
		if get_parent().is_ready:
			equip_node(get_parent())
		else:
			get_parent().connect("ready", self, "equip_node", [get_parent()])
	
	elif get_parent().owner is BasePerson:
		if get_parent().owner.is_ready:
			equip_node(get_parent().owner)
		else:
			get_parent().owner.connect("ready", self, "equip_node", [get_parent().owner])


func equip_node(node: BasePerson) -> bool:
	# assigns a hand to each handle
	var hands := node.borrow_hands(handles.size())
	if hands.empty():
		return false
	
	# assigning a hand to each handle
	for i in range(hands.size()):
		handles[handles.keys()[i]] = hands[i]
	
	player = node
	player.connect("aim", self, "aim_towards")
	player.equipment.append(self)
	
	# reparents the parent to the root of the first handle's hand
	get_parent().remove_child(self)
	hands[0].get_parent().add_child(self)
	
	transform = Transform.IDENTITY
	emit_signal("equipped", player)
	set_process(true)
	
	return true


func aim_towards(position: Vector3) -> void:
	look_at(position, Vector3.UP)
	rotate_object_local(Vector3.UP, PI)


func _process(delta):
	# moves the assigned hands towards the handles
	for handle in handles:
		handles[handle].global_transform = handle.global_transform
