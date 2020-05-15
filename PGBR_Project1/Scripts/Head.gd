extends Spatial


export var max_head_yaw := 50.0		# the maximum angle the head can turn by on the y axis, both left and right
export var max_head_pitch := 60.0
export var min_head_pitch := -60.0
export var turn_speed := 10.0

var _head_target_basis: Basis		# the basis the head tries to turn to
var _turn_head_to_target := false

func head_to_vector(rel_vec: Vector3):
	# turns the body towards the relative vector given
	# there is no need to flatten the vector as the head can look in any direction
	global_head_to_vector(rel_vec + global_transform.origin)


func global_head_to_vector(position: Vector3):
	# the same as turn to vector, except it turns the head to a global position
	_head_target_basis = global_transform.looking_at(position, Vector3.UP).basis
	_turn_head_to_target = true


func _physics_process(delta):
	if _turn_head_to_target:
		var target_transform = global_transform
		target_transform.basis = _head_target_basis
		global_transform = global_transform.interpolate_with(target_transform, turn_speed / 2 * delta)
		
		_turn_head_to_target = global_transform.basis.tdotz(_head_target_basis.z) < 0.99
	
	var head_rotation = rotation_degrees
	
	# sets the measured rotation in the y axis to be 0 if pointing in the same direction as this node
	# this is because the Head node has to be rotated 180 degrees because the Camera looks at the -z axis
	if head_rotation.y < 0:
		head_rotation.y = - 180 - head_rotation.y
	else:
		head_rotation.y = 180 - head_rotation.y
	
	# rotates the Person node so that the Head does not rotate past the max_head_yaw
	if head_rotation.y < - max_head_yaw:
		global_rotate(Vector3.UP, deg2rad(head_rotation.y + max_head_yaw) * turn_speed * delta)
		owner.global_rotate(Vector3.UP, - deg2rad(head_rotation.y + max_head_yaw) * turn_speed * delta)
		
	elif head_rotation.y > max_head_yaw:
		global_rotate(Vector3.UP, deg2rad(head_rotation.y - max_head_yaw) * turn_speed * delta)
		owner.global_rotate(Vector3.UP, - deg2rad(head_rotation.y - max_head_yaw) * turn_speed * delta)
	
	if head_rotation.x < min_head_pitch:
		rotation_degrees.x = min_head_pitch
	
	elif head_rotation.x > max_head_pitch:
		rotation_degrees.x = max_head_pitch
