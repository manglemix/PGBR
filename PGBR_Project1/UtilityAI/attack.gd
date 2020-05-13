class_name Attack
extends State


export(Curve) var value_curve
export var max_distance := 50.0

var _target


func get_score(employee: BasePerson) -> float:
	# employee is the node that is asking for the best action to do
	# this function returns how much 'value' there is when using the best_action offered by this script
	
	var valid_target := []
	for group in get_parent().hostile_groups:
		for enemy in get_tree().get_nodes_in_group(group):
			var collision = employee.get_world().direct_space_state.intersect_ray(employee.get_node("Head").global_transform.origin, enemy.global_transform.origin, [employee])
			
			if not collision.empty() and collision["collider"] == enemy:
				valid_target.append(enemy)
	
	if valid_target.empty():
		return 0.0
	
	var minimum := INF
	for enemy in valid_target:
		var distance = employee.global_transform.origin.distance_to(enemy.global_transform.origin)
		
		if distance < minimum:
			minimum = distance
			_target = enemy
	
	return value_curve.interpolate(minimum / 50)


func get_state(employee):
	var state = duplicate()
	state._target = _target
	return state


func _process(delta):
	var goto = get_parent().get_node_or_null("Goto") as AutoGoto
	
	if not is_instance_valid(_target):
		queue_free()
		if is_instance_valid(goto):
			goto.queue_free()
		return
	
	get_parent().fully_face_target(_target.global_transform.origin)
	
	if get_parent().guns[0].get_collider() == _target:
		get_parent().shoot_guns()
		
		if is_instance_valid(goto):
			goto.queue_free()
	
	elif is_instance_valid(goto):
		goto.set_path(_target.global_transform.origin)
	
	else:
		goto = AutoGoto.new(_target.global_transform.origin)
		goto.turn_head = false
		goto.connect("destination_reached", goto, "queue_free")
		goto.name = "Goto"
		get_parent().add_child(goto)
