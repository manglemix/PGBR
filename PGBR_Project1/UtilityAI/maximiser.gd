class_name Maximiser
extends Action


onready var _best_node := get_child(0)


func get_score() -> float:
	# this node looks at its children and finds which one has the highest score, and shows it off
	# if that score was the highest, it will be offered as the best_action
	var max_score: float
	
	for child in get_children():
		child.employee = employee
		var score = child.get_score()
		
		if is_inf(score):
			_best_node = child
			return score
		
		if score > max_score:
			_best_node = child
			max_score = score
	
	return max_score


func get_action(employee) -> Reference:
	return _best_node.get_action(employee) as Reference
