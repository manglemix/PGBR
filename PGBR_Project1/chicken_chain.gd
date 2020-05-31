# A versatile 100% accurate 2 bone IK system which still allows the root bone's parent to have animations
# The problem with SkeletonIK was that all the bones used in its IK chain could not be affected by animations
# So if the arm was holding a gun and the player crouched, the arm would be in the air
class_name ChickenChain
extends Node


export(Array, NodePath) var bone_attachments := []
export var ik_path: NodePath

onready var root_attachment := get_node(bone_attachments[0]) as RestBoneAttachment
onready var root_proxy_node := root_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var joint_attachment := get_node(bone_attachments[1]) as RestBoneAttachment
onready var joint_proxy_node := joint_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var tail_attachment := get_node(bone_attachments[2]) as RestBoneAttachment
onready var tail_proxy_node := tail_attachment.get_node("Pose/TransformProxy") as TransformProxy

onready var root_length := root_attachment.global_transform.origin.distance_to(joint_attachment.global_transform.origin)
onready var tail_length := joint_attachment.global_transform.origin.distance_to(tail_attachment.global_transform.origin)

onready var ik_node := get_node(ik_path) as Spatial


func _ready():
	assert(bone_attachments.size() == 3)


func _process(delta):
	var target_distance := root_attachment.global_transform.origin.distance_to(ik_node.global_transform.origin)
	
	$Joint.global_transform.origin = (root_attachment.global_transform.origin + ik_node.global_transform.origin) / 2
	
	if target_distance < root_length + tail_length:
		var joint_normal := ($Magnet.global_transform.origin - $Joint.global_transform.origin).normalized() as Vector3
		var joint_offset := root_length * sqrt(1 - pow((root_length * root_length + tail_length * tail_length - target_distance * target_distance) / 2 / root_length / tail_length, 2))
		$Joint.global_transform.origin += joint_normal * joint_offset
