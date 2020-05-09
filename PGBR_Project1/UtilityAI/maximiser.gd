class_name Maximiser
extends Action


func get_score() -> float:
	# this node looks at its children and finds which one has the highest score, and shows it off
	# if that score was the highest, it will be offered as the best_action
	var max_score: float
	
	for child in get_children():
		var score = child.get_score(employee, scene)
		
		if is_inf(score):
			best_action = child
			break
		
		if score > max_score:
			best_action = child
			max_score = score
	
	return max_score
