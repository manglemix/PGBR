class_name UtilityTree
extends Node


func _process(delta):
	for group in get_groups():
		if group == "idle_process":
			continue
		
		for employee in get_tree().get_nodes_in_group(group):
			if employee == self:
				continue
			
			var state = employee.get_node_or_null(group + "State")
			
			if not is_instance_valid(state):
				# if there was no state assigned to the employee, give it one
				get_child(0).get_score(employee)	# sometimes some nodes need their score checked first
				state = get_child(0).get_state()
				state.name = group + "State"
				
				if is_instance_valid(state.get_parent()):
					state.get_parent().remove_child(state)
				
				employee.add_child(state)
				state.set_process(true)
