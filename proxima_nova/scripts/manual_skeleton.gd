class_name ManualSkeleton
extends Spatial


export var extra_length: float
export var skeleton_ik_path: NodePath

onready var _skeleton_ik := get_node(skeleton_ik_path) as SkeletonIK
onready var _skeleton := _skeleton_ik.get_parent_skeleton() as Skeleton
onready var bone_idx := _skeleton.find_bone(_skeleton_ik.root_bone) as int
onready var tip_idx := _skeleton.find_bone(_skeleton_ik.tip_bone)
onready var elbow_idx := _skeleton.get_bone_parent(tip_idx)
onready var chain_length := _skeleton.get_bone_rest(tip_idx).origin.length() + _skeleton.get_bone_rest(elbow_idx).origin.length() + extra_length
onready var ik_target := get_node(_skeleton_ik.target_node) as Spatial


#func _process(_delta):
#	transform = _skeleton.get_bone_global_pose(bone_idx)
#	var ik_vector := ik_target.global_transform.origin - global_transform.origin
#	var global_magnet := _skeleton.global_transform.xform(_skeleton_ik.magnet) as Vector3
#	$End.global_transform = ik_target.global_transform
#
#	if ik_vector.length() > chain_length:
#		$End.global_transform.origin = global_transform.origin + ik_vector.normalized() * chain_length
#		$Joint.global_transform = global_transform.interpolate_with($End.global_transform, 0.5)
#
#	else:
#		$Joint.global_transform = global_transform.interpolate_with(ik_target.global_transform, 0.5)
#		var height := sqrt(chain_length * chain_length - global_transform.origin.distance_squared_to(ik_target.global_transform.origin)) / 2 as float
#		$Joint.global_transform.origin += (global_magnet - $Joint.global_transform.origin).normalized() * height
#
#	var tmp := _skeleton.get_bone_global_pose(tip_idx)
#	tmp.origin = (transform * $End.transform)
#	_skeleton.set_bone_global_pose_override(tip_idx, transform * $End.transform, 1.0, true)
#	_skeleton.set_bone_global_pose_override(elbow_idx, transform * $Joint.transform, 1.0, true)
#	_skeleton.set_bone_global_pose_override(bone_idx, transform, 1.0, true)
