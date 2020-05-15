class_name VirtualBone
extends Node


export var skeleton_path := NodePath("..")

var transform: Transform setget set_transform, get_transform
var global_transform: Transform setget set_global_transform, get_global_transform
var rotation: Vector3 setget set_rotation, get_rotation
var rotation_degrees: Vector3 setget set_rotation_degrees, get_rotation_degrees

onready var skeleton := get_node(skeleton_path) as Skeleton
onready var bone_idx := skeleton.find_bone(name)


func set_transform(value: Transform):
	skeleton.set_bone_pose(bone_idx, value)


func get_transform():
	return skeleton.get_bone_pose(bone_idx)


func set_global_transform(value: Transform):
	skeleton.set_bone_pose(bone_idx, skeleton.global_transform.xform_inv(value))


func get_global_transform():
	return skeleton.global_transform.xform(skeleton.get_bone_pose(bone_idx))


func set_rotation(value: Vector3):
	var transform := skeleton.get_bone_pose(bone_idx)
	transform.basis = Basis(value)
	skeleton.set_bone_pose(bone_idx, transform)


func get_rotation():
	return skeleton.get_bone_pose(bone_idx).basis.get_euler()


func set_rotation_degrees(value: Vector3):
	set_rotation(_vector_deg2rad(value))


func get_rotation_degrees():
	return _vector_rad2deg(get_rotation())


static func _vector_rad2deg(vector: Vector3):
	return Vector3(rad2deg(vector.x),
				   rad2deg(vector.y),
				   rad2deg(vector.z)
					)


static func _vector_deg2rad(vector: Vector3):
	return Vector3(deg2rad(vector.x),
				   deg2rad(vector.y),
				   deg2rad(vector.z)
					)
