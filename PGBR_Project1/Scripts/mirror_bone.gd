# Mirrors the transform of the parent to the bone of the same name as the node, in the _skeleton given
class_name MirrorBone
extends Node


export var _skeleton_path: NodePath
export var invert_y := false
export var override_bone := false

onready var _skeleton := get_node(_skeleton_path) as Skeleton
onready var bone_idx := _skeleton.find_bone(name) as int


func _process(_delta):
	if invert_y:
		if override_bone:
			_skeleton.set_bone_global_pose_override(bone_idx, get_parent().transform, 1.0, true)
		else:
			_skeleton.set_bone_pose(bone_idx, get_parent().transform)
	
	else:
		var tmp := get_parent().transform as Transform
		tmp = tmp.rotated(tmp.basis.x, tmp.basis.get_euler().x * - 2)
		if override_bone:
			_skeleton.set_bone_global_pose_override(bone_idx, tmp, 1.0, true)
		else:
			_skeleton.set_bone_pose(bone_idx, tmp)
