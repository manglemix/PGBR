# Similar to BoneAttachment, but instead sets it's local transform to its bone's rest transform
tool
class_name RestBoneAttachment
extends Spatial


export var _skeleton_path := NodePath("..")			# A path to the skeleton node
export var _bone_name: String

var dont_save = ["_skeleton"]

onready var _skeleton := get_node(_skeleton_path) as Skeleton
onready var _bone_idx := _skeleton.find_bone(_bone_name) as int
onready var _bone_parent := _skeleton.get_bone_parent(_bone_idx) as int


func _process(_delta):
	transform = _skeleton.get_bone_global_pose(_bone_parent) * _skeleton.get_bone_rest(_bone_idx)
