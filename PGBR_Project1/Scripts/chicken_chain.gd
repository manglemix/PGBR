# A versatile 100% accurate 2 bone IK system which still allows the root bone's parent to have animations
# The problem with SkeletonIK was that all the bones used in its IK chain could not be affected by animations
# So if the arm was holding a gun and the player crouched, the arm would be in the air
tool
class_name ChickenChain
extends Node


export var root_path: NodePath
export var joint_path: NodePath
export var tail_path: NodePath
export var ik_path: NodePath
export var override_tip_basis := true
export var active := true setget set_active

var dont_save := ["root_attachment", "root_proxy_node", "joint_attachment", "joint_proxy_node", "tail_attachment", "tail_proxy_node", "ik_node"]

onready var root_attachment := get_node(root_path) as RestBoneAttachment
onready var root_proxy_node := root_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var joint_attachment := get_node(joint_path) as RestBoneAttachment
onready var joint_proxy_node := joint_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var tail_attachment := get_node(tail_path) as RestBoneAttachment
onready var tail_proxy_node := tail_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var root_length := root_attachment.global_transform.origin.distance_to(joint_attachment.global_transform.origin)
onready var tail_length := joint_attachment.global_transform.origin.distance_to(tail_attachment.global_transform.origin)

onready var ik_node := get_node(ik_path) as Spatial


func set_active(value: bool):
	if not is_instance_valid(root_attachment):
		return
	
	active = value
	set_process(value)
	root_attachment.get_node("Pose").active = value
	joint_attachment.get_node("Pose").active = value
	tail_attachment.get_node("Pose").active = value


func _ready():
	set_active(active)


func _process(_delta):
	var target_vector := ik_node.global_transform.origin - root_attachment.global_transform.origin
	var target_distance := target_vector.length()

	$Joint.global_transform.origin = root_attachment.global_transform.origin + target_vector.normalized() * root_length
	
	if target_distance < root_length + tail_length:
		var joint_normal := ($Magnet.global_transform.origin - $Joint.global_transform.origin).normalized() as Vector3
		var joint_offset := sqrt(pow(root_length, 2) - pow((pow(root_length, 2) - pow(tail_length, 2) + pow(target_distance, 2)) / 2 / target_distance, 2))
		$Joint.global_transform.origin += joint_normal * joint_offset
		
		root_proxy_node.look_at($Joint.global_transform.origin, root_attachment.global_transform.basis.z)
		var joint_axis = root_proxy_node.global_transform.origin - $Joint.global_transform.origin
		joint_axis = joint_axis.cross(ik_node.global_transform.origin - joint_proxy_node.global_transform.origin)
		joint_proxy_node.look_at(ik_node.global_transform.origin, joint_axis.normalized())
		
	else:
		root_proxy_node.look_at(ik_node.global_transform.origin, root_attachment.global_transform.basis.z)
		joint_proxy_node.look_at(ik_node.global_transform.origin, joint_attachment.global_transform.basis.z)
	
	if override_tip_basis:
		tail_proxy_node.global_transform.basis = ik_node.global_transform.basis
