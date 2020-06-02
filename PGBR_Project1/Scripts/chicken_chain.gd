# A versatile 100% accurate 2 bone IK system which still allows the root bone's parent to have animations
# The problem with SkeletonIK was that all the bones used in its IK chain could not be affected by animations
# So if the arm was holding a gun and the player crouched, the arm would be in the air
tool
class_name ChickenChain
extends Node


export var _root_path: NodePath
export var _joint_path: NodePath
export var _tail_path: NodePath
export var _ik_path: NodePath				# the node the bone chain will move to
export var _magnet_path: NodePath			# the node which the joint will point to
export var override_tip_basis := true		# if true, the tail bone will copy the transform of the ik node
export var active := true setget set_active

var dont_save := ["_root_attachment", "_root_proxy_node", "_joint_attachment", "_joint_proxy_node", "_tail_attachment", "_tail_proxy_node", "_ik_node"]

onready var _root_attachment := get_node(_root_path) as RestBoneAttachment
onready var _root_proxy_node := _root_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var _joint_attachment := get_node(_joint_path) as RestBoneAttachment
onready var _joint_proxy_node := _joint_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var _tail_attachment := get_node(_tail_path) as RestBoneAttachment
onready var _tail_proxy_node := _tail_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var _root_length := _root_attachment.global_transform.origin.distance_to(_joint_attachment.global_transform.origin)
onready var _tail_length := _joint_attachment.global_transform.origin.distance_to(_tail_attachment.global_transform.origin)

onready var _ik_node := get_node(_ik_path) as Spatial
onready var _magnet := get_node(_magnet_path) as Spatial


func set_active(value: bool):
	if not is_instance_valid(_root_attachment):
		return
	
	active = value
	set_process(value)
	_root_attachment.get_node("Pose").active = value
	_joint_attachment.get_node("Pose").active = value
	_tail_attachment.get_node("Pose").active = value


func _ready():
	set_active(active)


func _process(_delta):
	var target_vector := _ik_node.global_transform.origin - _root_attachment.global_transform.origin
	var target_distance := target_vector.length()

	$Joint.global_transform.origin = _root_attachment.global_transform.origin + target_vector.normalized() * _root_length
	
	if target_distance < _root_length + _tail_length:
		var joint_normal := (_magnet.global_transform.origin - $Joint.global_transform.origin).normalized() as Vector3
		var joint_offset := sqrt(pow(_root_length, 2) - pow((pow(_root_length, 2) - pow(_tail_length, 2) + pow(target_distance, 2)) / 2 / target_distance, 2))
		$Joint.global_transform.origin += joint_normal * joint_offset
		
		_root_proxy_node.look_at($Joint.global_transform.origin, _root_attachment.global_transform.basis.z)
		var joint_axis = _root_proxy_node.global_transform.origin - $Joint.global_transform.origin
		joint_axis = joint_axis.cross(_ik_node.global_transform.origin - _joint_proxy_node.global_transform.origin)
		_joint_proxy_node.look_at(_ik_node.global_transform.origin, joint_axis.normalized())
		
	else:
		_root_proxy_node.look_at(_ik_node.global_transform.origin, _root_attachment.global_transform.basis.z)
		_joint_proxy_node.look_at(_ik_node.global_transform.origin, _joint_attachment.global_transform.basis.z)
	
	if override_tip_basis:
		_tail_proxy_node.global_transform.basis = _ik_node.global_transform.basis
