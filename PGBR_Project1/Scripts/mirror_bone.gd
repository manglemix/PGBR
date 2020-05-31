# Mirrors the transform of the parent to the bone of the same name as the node, in the skeleton given
tool
class_name MirrorBone
extends BoneData

export var target_path := NodePath("..")
export var active := true setget set_active
export var compensate_rest := false		# if true, it is assumed that the parent's transform should be the absolute transform, and thus includes the rest pose
export var ignore_origin := true	# if true, the parent's transform is not applied to the bone

onready var target := get_node(target_path) as Spatial


func set_active(value: bool):
	active = value
	set_process(value)


func reset():
	skeleton.set_bone_pose(bone_idx, Transform.IDENTITY)


func _ready():
	dont_save.append("target")
	set_process(active)


func _process(_delta):
	var tmp := target.transform as Transform
	
	if compensate_rest:
		tmp *= skeleton.get_bone_rest(bone_idx).affine_inverse()
	
	if ignore_origin:
		tmp.origin  = Vector3.ZERO
	
	skeleton.set_bone_pose(bone_idx, tmp)
