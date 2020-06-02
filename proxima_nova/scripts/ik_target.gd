class_name IKtarget
extends Spatial


export var _skeleton_ik_path: NodePath				# the path to the SkeletonIK which is using this node as a target

onready var _skeleton_ik := get_node(_skeleton_ik_path) as SkeletonIK
onready var _skeleton := _skeleton_ik.get_parent_skeleton()
onready var _bone_idx := _skeleton.find_bone(_skeleton_ik.tip_bone)


func start(one_time:=false):
	_skeleton_ik.start(one_time)


func stop():
	_skeleton_ik.stop()


func _process(delta):
	# this keeps the IK node attached to the bone by moving this node
	global_transform = _skeleton.global_transform * _skeleton.get_bone_global_pose(_bone_idx) * get_node("IK").transform.affine_inverse()
