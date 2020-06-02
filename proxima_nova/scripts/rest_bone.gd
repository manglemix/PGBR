# Similar to BoneAttachment, but instead sets it's local transform to its bone's rest transform
tool
class_name RestBoneAttachment
extends Spatial


export var _bone_name: String

onready var _bone_idx := get_parent().find_bone(_bone_name) as int
onready var _bone_parent := get_parent().get_bone_parent(_bone_idx) as int


func _process(_delta):
	transform = get_parent().get_bone_global_pose(_bone_parent) * get_parent().get_bone_rest(_bone_idx)
