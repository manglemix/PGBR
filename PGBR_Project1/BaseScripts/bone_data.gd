class_name BoneData
extends Spatial


export var _skeleton_path: NodePath
export var _bone_name: String			# if not given, the name of the node is used instead

var bone_idx: int
var dont_save := ["skeleton", "_bone_name"]

onready var skeleton := get_node(_skeleton_path) as Skeleton setget set_skeleton


func set_bone_name(name: String):
	bone_idx = skeleton.find_bone(name)


func get_bone_name() -> String:
	return skeleton.get_bone_name(bone_idx)


func set_skeleton(node: Skeleton):
	_bone_name = skeleton.get_bone_name(bone_idx)
	skeleton = node
	set_bone_name(_bone_name)


func _ready():
	if _bone_name.empty():
		_bone_name = name
	
	set_bone_name(_bone_name)
