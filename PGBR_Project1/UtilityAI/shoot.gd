class_name Shoot
extends Action


export(Curve) var value_curve
export var max_distance := 50.0

var _target


func get_score(employee: BasePerson) -> float:
	# employee is the node that is asking for the best action to do
	# this function returns how much 'value' there is when using the best_action offered by this script
	
	var valid_target := []
	for enemy in get_action_tree().opponent_nodes:
		var collision = employee.get_world().direct_space_state.intersect_ray(employee.get_node("Head").global_transform.origin, enemy.global_transform.origin, [employee])
		
		if not collision.empty() and collision["collider"] == enemy:
			valid_target.append(enemy)
	
	if valid_target.empty():
		print("lol")
		return 0.0
	
	var minimum := INF
	for enemy in valid_target:
		var distance = employee.global_transform.origin.distance_to(enemy.global_transform.origin)
		
		if distance < minimum:
			minimum = distance
			_target = enemy
	
	return value_curve.interpolate(minimum / 50)


func get_action(employee) -> Reference:
	return ShootAction.new(employee, _target)


class ShootAction:
	var employee: BasePerson
	var target
	
	func _init(node: BasePerson, target):
		employee = node
		self.target = target
	
	func process(delta) -> int:
		if not is_instance_valid(target):
			return 2
		
		employee.fully_face_target(target.global_transform.origin)
		employee.shoot_guns()
		return 1
	
	func end() -> void:
		return
