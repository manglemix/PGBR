# this fits a capsule collider between the parent's origin and the top node's origin
class_name SqueezedCollider
extends CollisionShape


export var _top_node_path: NodePath
export var _transform_parent_path: NodePath		
export var _bottom_node_path: NodePath

var transform_parent: Spatial

onready var top_node := get_node(_top_node_path) as Spatial
onready var bottom_node := get_node(_bottom_node_path)


func _ready():
	assert(shape is CapsuleShape)
	if _transform_parent_path.is_empty():
		transform_parent = self
	else:
		transform_parent = get_node(_transform_parent_path)


func _process(delta):
	shape.height = top_node.global_transform.origin.y - bottom_node.global_transform.origin.y - 2 * shape.radius
	transform_parent.global_transform.origin.y = bottom_node.global_transform.origin.y + shape.height / 2 + shape.radius
