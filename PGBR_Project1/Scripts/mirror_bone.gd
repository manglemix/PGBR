# Mirrors the transform of the parent to the bone of the same name as the node, in the _skeleton given
class_name MirrorBone
extends Node


export var _skeleton_path: NodePath
export var bone_name: String

onready var _skeleton := get_node(_skeleton_path) as Skeleton
onready var bone_idx := _skeleton.find_bone(bone_name) as int


func _process(_delta):
	_skeleton.set_bone_pose(bone_idx, get_parent().transform)
