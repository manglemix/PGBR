class_name IKtarget
extends Spatial

export var _skeleton_ik_path: NodePath		# the path to the SkeletonIK which is using this node as a target
export var lock_to_bone := true setget set_lock_to_bone	# If locked to bone, IK is disabled and this ndoe will copy the bone it is assigned to

var bone_idx: int	# the bone index of this node


var _skeleton: Skeleton
var _skeleton_ik: SkeletonIK


func _ready():
	_skeleton_ik = get_node(_skeleton_ik_path)
	_skeleton = _skeleton_ik.get_parent()
	bone_idx = _skeleton.find_bone(name)
	set_lock_to_bone(lock_to_bone)


func set_lock_to_bone(value: bool):
	lock_to_bone = value
	if not is_instance_valid(_skeleton_ik):
		# setter is called on exported variable even before ready, so we have to exit the function to prevent crash
		# this is because _skeleton_ik will be null before ready. However, the setter will be called again in _ready
		return
	
	if value:
		_skeleton_ik.stop()
	else:
		_skeleton_ik.start()
	
	set_process(value)


func _process(delta):
	var bone_transform := _skeleton.get_bone_global_pose(bone_idx)
	global_transform = _skeleton.global_transform * bone_transform
