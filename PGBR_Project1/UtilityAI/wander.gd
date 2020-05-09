class_name Wander
extends Action


func get_score() -> float:
	if len(get_tree().get_nodes_in_group("Friendly")) == 0:
		return INF
	return 0.0


func execute() -> int:
	print("lol")
	return CAN_CHANGE
