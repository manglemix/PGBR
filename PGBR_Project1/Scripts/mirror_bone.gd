# Mirrors the transform of the parent to the bone of the same name as the node, in the _skeleton given
tool
class_name MirrorBone
extends Spatial


export var _skeleton_path := NodePath("..")
export var _bone_name: String
export var use_own_transform := false
export var active := true setget set_active
export var compensate_rest := false			# if true, it is assumed that the parent's transform should be the absolute transform, and thus includes the rest pose
export var ignore_origin := true			# if true, the target's position is not applied to the bone
export var override_animation := false		# if true, any animation applied to the target bone is overwritten

var dont_save := ["_skeleton", "_bone_name"]

onready var _skeleton := get_node(_skeleton_path) as Skeleton
onready var _bone_idx := _skeleton.find_bone(_bone_name)


func set_active(value: bool):
	active = value
	set_process(value)


func reset():
	_skeleton.set_bone_pose(_bone_idx, Transform.IDENTITY)


func _ready():
	dont_save.append("target")
	set_process(active)


func _process(_delta):
	var tmp: Transform
	if use_own_transform:
		tmp = transform
	else:
		tmp = get_parent().transform
	
	if compensate_rest:
		tmp *= _skeleton.get_bone_rest(_bone_idx).affine_inverse()
	
	if ignore_origin:
		tmp.origin  = Vector3.ZERO
	
	if override_animation:
		if use_own_transform:
			tmp = get_parent().global_transform * tmp
		else:
			tmp = get_parent().get_parent().global_transform * tmp
		
		tmp = _skeleton.global_transform.affine_inverse() * tmp
		_skeleton.set_bone_global_pose_override(_bone_idx, tmp, 1.0, true)
		
	else:
		_skeleton.set_bone_pose(_bone_idx, tmp)
