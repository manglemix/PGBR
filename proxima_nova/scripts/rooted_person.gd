class_name RootedPerson
extends BasePerson


func _integrate_velocity(vector: Vector3, delta: float) -> Vector3:
	# this will check for root motion, and move the Person correspondingly
	var tmp := global_transform
	tmp.origin = Vector3.ZERO
	tmp *= $Animator.get_root_motion_transform()
	return tmp.origin / delta
