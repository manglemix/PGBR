# Enforces rotation limits, applies excess rotation onto the fallback_node, and can be made to target a global position
class_name PivotPoint
extends Spatial


export var _fallback_node_path := NodePath('..')		# the path to the fallback_node
export var max_pitch := 70.0
export var min_pitch := - 70.0
export var max_yaw := 45.0
export var min_yaw := -45.0
export var limit_pitch := true		# if true, excess rotation in this axis will not be applied to the fallback_node
export var limit_yaw := false
export var turn_speed := 6.0		# used for interpolating to the target orientation
export var sticky_parent := false	# if true, the fallback_node will always try to turn to its zero point

var _target_transform: Transform

onready var fallback_node := get_node(_fallback_node_path) as Spatial			# the node which excess rotation from this node will be dumped onto
onready var _initial_transform := transform		# the initial orientation will become the zero point


func _ready():
	set_process(false)


func biaxial_rotate(x: float, y: float) -> void:
	global_rotate(fallback_node.global_transform.basis.y.normalized(), y)
	rotate_object_local(Vector3.RIGHT, x)


func turn_to_vector(rel_vec: Vector3):
	global_turn_to_vector(rel_vec + global_transform.origin)


func global_turn_to_vector(position: Vector3):
	_target_transform = global_transform.looking_at(position, fallback_node.global_transform.basis.y)
	_target_transform = _target_transform.rotated(_target_transform.basis.y, PI)
	set_process(true)


func get_final_transform() -> Transform:
	# finds the transform relative to the _initial_transform
	return transform * _initial_transform.affine_inverse()


func _process(delta):
	_target_transform.origin = global_transform.origin
	global_transform = global_transform.interpolate_with(_target_transform, turn_speed * delta)

	if global_transform.basis.tdotz(_target_transform.basis.z) >= 0.99:
		set_process(false)


func _physics_process(_delta):
	if sticky_parent:
		var parent_transform: Transform
		if fallback_node.has_method("get_final_transform"):
			parent_transform = fallback_node.get_final_transform()
		
		else:
			parent_transform = fallback_node.transform
		
		var euler_rotation := parent_transform.basis.get_euler()
		
		# we do it this way instead of using biaxial_rotate just in case the fallback_node is not a PivotPoint
		fallback_node.global_rotate(fallback_node.global_transform.basis.y.normalized(), - euler_rotation.y)
		fallback_node.rotate_object_local(Vector3.RIGHT, - euler_rotation.x)
		
		biaxial_rotate(euler_rotation.x, euler_rotation.y)
	
	var euler_rotation := get_final_transform().basis.get_euler()
	euler_rotation = Vector3(rad2deg(euler_rotation.x),
							rad2deg(euler_rotation.y),
							rad2deg(euler_rotation.z)
							)
	
	if euler_rotation.y > max_yaw:
		if not limit_yaw:
			fallback_node.rotate_object_local(Vector3.UP, deg2rad(euler_rotation.y - max_yaw))
		
		global_rotate(fallback_node.global_transform.basis.y.normalized(), deg2rad(max_yaw - euler_rotation.y))
		
	elif euler_rotation.y < min_yaw:
		if not limit_yaw:
			fallback_node.rotate_object_local(Vector3.UP, deg2rad(euler_rotation.y - min_yaw))
		
		global_rotate(fallback_node.global_transform.basis.y.normalized(), deg2rad(min_yaw - euler_rotation.y))

	if euler_rotation.x > max_pitch:
		if not limit_pitch:
			fallback_node.global_rotate(global_transform.basis.x.normalized(), deg2rad(euler_rotation.x - max_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(max_pitch - euler_rotation.x))
		
	elif euler_rotation.x < min_pitch:
		if not limit_pitch:
			fallback_node.global_rotate(global_transform.basis.x.normalized(), deg2rad(euler_rotation.x - min_pitch))
		
		rotate_object_local(Vector3.RIGHT, deg2rad(min_pitch - euler_rotation.x))
