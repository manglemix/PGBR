tool
extends Spatial


export var skeleton_path: NodePath
export var bone_name: String

onready var _skeleton := get_node(skeleton_path) as Skeleton
onready var _bone_idx := _skeleton.find_bone(bone_name)


func _process(_delta):
	transform = _skeleton.get_bone_rest(_bone_idx)
