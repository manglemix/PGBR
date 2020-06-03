# A base class for items which can be held in hands (hand is a broad term, generally they just mean points of contact)
class_name Equippable
extends Spatial


export(Array, NodePath) var _handle_paths := []

var handles := {}
var player: Node

func _ready():
	assert(not _handle_paths.empty())
	for path in _handle_paths:
		handles[get_node(path)] = null
	
	if get_parent() is BasePerson:
		get_parent().connect("ready", self, "equip_node", [get_parent(), true])
	
	elif get_parent().owner is BasePerson:
		get_parent().owner.connect("ready", self, "equip_node", [get_parent().owner, true])


func equip_node(node: Node, try_assert:=false) -> bool:
	# the try assert is to cause the game to crash if the gun could not be equipped
	# useful if the gun did not get equipped at the start of the level during development
	for handle in handles:
		var hand = node.borrow_hand()
		
		if not is_instance_valid(hand):
			if try_assert:
				assert(false)
			return false
		
		handles[handle] = hand
	
	player = node
	player.connect("shoot", self, "shoot")
	player.connect("aim", self, "aim_towards")
	player.equipment.append(self)
	
	get_parent().remove_child(self)
	handles.values()[0].get_parent().add_child(self)
	transform = handles.values()[0].transform
	
	for handle in handles:
		handles[handle].global_transform = handle.global_transform
	
	return true
