# Mirrors the transform of the parent to the bone of the same name as the node, in the skeleton given
class_name MirrorBone
extends Node


export var skeleton_path: NodePath
export var invert_y := false

onready var skeleton := get_node(skeleton_path) as Skeleton
onready var bone_idx := skeleton.find_bone(name)


func _process(_delta):
	if invert_y:
		skeleton.set_bone_pose(bone_idx, get_parent().transform)
	
	else:
		var tmp := get_parent().transform as Transform
		tmp = tmp.rotated(tmp.basis.x, tmp.basis.get_euler().x * - 2)
		skeleton.set_bone_pose(bone_idx, tmp)
