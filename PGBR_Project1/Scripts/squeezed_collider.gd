# this fits a capsule collider between the parent's origin and the top node's origin
class_name SqueezedCollider
extends CollisionShape


export var top_node_path: NodePath
export var transform_parent_path: NodePath
export var bottom_node_path: NodePath

onready var _top_node := get_node(top_node_path) as Spatial
onready var _bottom_node := get_node(bottom_node_path)
onready var _transform_parent := get_node(transform_parent_path) as RemoteTransform


func _ready():
	assert(shape is CapsuleShape)


func _process(delta):
	shape.height = _top_node.global_transform.origin.y - _bottom_node.global_transform.origin.y - 2 * shape.radius
	_transform_parent.global_transform.origin.y = _bottom_node.global_transform.origin.y + shape.height / 2 + shape.radius
