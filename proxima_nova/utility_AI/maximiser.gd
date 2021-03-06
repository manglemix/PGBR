class_name Maximiser
extends State


signal calling_get_score(employee)

var _best_node: State


func get_score(employee) -> float:
	emit_signal("calling_get_score", employee)
	# this node looks at its children and finds which one has the highest score, and shows it off
	# if that score was the highest, it will be offered as the best state
	var max_score := -INF
	
	for child in get_children():
		var score = child.get_score(employee)
		
		if is_inf(score):
			_best_node = child
			return score
		
		if score > max_score:
			_best_node = child
			max_score = score
	
	return max_score


func get_state(employee):
	return _best_node.get_state(employee)
