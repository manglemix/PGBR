# A base class for items which can be held in hands (hand is a broad term, generally they just mean points of contact)
class_name Equippable
extends Node


export(Array, NodePath) var _handle_paths := []

var dont_save := ["handles", "player", "_director"]
var handles := {}
var player: BasePerson

onready var _director := get_tree().get_current_scene() as Director


func _ready():
	set_process(false)
	for path in _handle_paths:
		handles[get_node(path)] = null
	
	if get_parent().get_parent() is BasePerson:
		get_parent().get_parent().connect("ready", self, "equip_node", [get_parent().get_parent(), true])
	
	elif get_parent().get_parent().owner is BasePerson:
		get_parent().get_parent().owner.connect("ready", self, "equip_node", [get_parent().get_parent().owner, true])





func equip_node(node: BasePerson) -> bool:
	# assigns a hand to each handle
	var tmp_hands := []
	for handle in handles:
		var hand = node.borrow_hand()
		tmp_hands.append(hand)
		
		if not is_instance_valid(hand):
			# return all hands that were borrowed if there weren't enough
			for tmp_hand in tmp_hands:
				node.return_hand(tmp_hand)
			
			get_parent().get_parent().remove_child(get_parent())
			_director.get_branch(self).add_child(self)
			return false
		
		handles[handle] = hand
	
	player = node
	player.connect("shoot", self, "shoot")
	player.connect("aim", self, "aim_towards")
	player.equipment.append(self)
	
	# reparents the parent to the first handle's parent
	get_parent().get_parent().remove_child(get_parent())
	handles.values()[0].get_parent().add_child(get_parent())
	
	get_parent().transform = Transform.IDENTITY
	
	set_process(true)
	
	return true


func _process(delta):
	# moves the assigned hands towards the handles
	for handle in handles:
		handles[handle].global_transform = handle.global_transform
