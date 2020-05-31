tool
class_name ExternalBoneAttachment
extends BoneData


func _process(_delta):
	transform = skeleton.get_bone_rest(bone_idx)
