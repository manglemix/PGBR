class_name IKtarget
extends Spatial


export var lock_to_bone := false setget set_lock_to_bone
export var _skeleton_ik_path: NodePath

var bone_idx: int

var _skeleton: Skeleton
var _skeleton_ik: SkeletonIK


func _ready():
	_skeleton_ik = get_node(_skeleton_ik_path)
	_skeleton = _skeleton_ik.get_parent()
	bone_idx = _skeleton.find_bone(name)
	set_lock_to_bone(lock_to_bone)


func set_lock_to_bone(value: bool):
	if value:
		_skeleton_ik.stop()
	else:
		_skeleton_ik.start()
	
	set_process(value)
	lock_to_bone = value


func _process(delta):
	var bone_transform := _skeleton.get_bone_global_pose(bone_idx)
	global_transform = _skeleton.global_transform * bone_transform
