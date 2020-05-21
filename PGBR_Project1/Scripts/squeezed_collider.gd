# this fits a capsule collider between the parent's origin and the top node's origin
class_name SqueezedCollider
extends CollisionShape


export var _top_node_path: NodePath				# the node which this collider will try to stay exactly under
export var _bottom_node_path: NodePath			# the node which this collider will try to stay exactly over
export var _transform_parent_path: NodePath		# usually CollisionShapes have RemoteTransforms applied onto them as they must be directly parented to a PhysicsBody, if so, set the path here

var transform_parent: Spatial		# In the event a RemoteTransform is assigned to this CollisionShape, moving self will not do anything, so the RemoteTransform must be moved instead

onready var top_node := get_node(_top_node_path) as Spatial
onready var bottom_node := get_node(_bottom_node_path)


func _ready():
	assert(shape is CapsuleShape)
	if _transform_parent_path.is_empty():
		transform_parent = self
	else:
		transform_parent = get_node(_transform_parent_path)


func _process(delta):
	# the radius remains constant, but the height and the vertical position will change to stay between the top node and bottom node
	shape.height = top_node.global_transform.origin.y - bottom_node.global_transform.origin.y - 2 * shape.radius
	transform_parent.global_transform.origin.y = bottom_node.global_transform.origin.y + shape.height / 2 + shape.radius
