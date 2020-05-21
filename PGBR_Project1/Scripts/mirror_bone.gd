# Mirrors the transform of the parent to the bone of the same name as the node, in the skeleton given
class_name MirrorBone
extends Node


export var _skeleton_path: NodePath
export var bone_name: String		# if not given, the name of the node is used instead
export var ignore_origin := true	# if true, the parent's transform is not applied to the bone

var bone_idx: int

onready var skeleton := get_node(_skeleton_path) as Skeleton


func _ready():
	if bone_name.empty():
		bone_idx = skeleton.find_bone(name)
	else:
		bone_idx = skeleton.find_bone(bone_name)


func _process(_delta):
	if ignore_origin:
		var tmp := get_parent().transform as Transform
		tmp.origin  = Vector3.ZERO
		skeleton.set_bone_pose(bone_idx, tmp)
	else:
		skeleton.set_bone_pose(bone_idx, get_parent().transform)
