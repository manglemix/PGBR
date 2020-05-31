# Similar to BoneAttachment, but instead sets it's local transform to its bone's rest transform
tool
class_name RestBoneAttachment
extends BoneData


func _process(_delta):
	transform = skeleton.get_bone_global_pose(bone_idx) * skeleton.get_bone_pose(bone_idx).affine_inverse()
