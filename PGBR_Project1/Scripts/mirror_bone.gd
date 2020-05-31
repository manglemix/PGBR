# Mirrors the transform of the parent to the bone of the same name as the node, in the skeleton given
tool
class_name MirrorBone
extends BoneData


export var ignore_origin := true	# if true, the parent's transform is not applied to the bone


func _process(_delta):
	if ignore_origin:
		var tmp := get_parent().transform as Transform
		tmp.origin  = Vector3.ZERO
		skeleton.set_bone_pose(bone_idx, tmp)
	else:
		skeleton.set_bone_pose(bone_idx, get_parent().transform)
