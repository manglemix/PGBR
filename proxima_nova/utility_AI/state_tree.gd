class_name UtilityTree
extends Node


export var group_name: String


func _process(_delta):
	for employee in get_tree().get_nodes_in_group(group_name):
		if employee == self:
			continue
		
		var state = employee.get_node_or_null(group_name + "State")
		
		if not is_instance_valid(state):
			# if there was no state assigned to the employee, give it one
			get_child(0).get_score(employee)	# sometimes some nodes need their score checked first
			state = get_child(0).get_state(employee)
			state.name = group_name + "State"
			
			employee.add_child(state)
			state.set_process(true)
