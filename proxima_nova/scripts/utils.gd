extends Node

func map(x: float, in_min: float, in_max: float, out_min: float, out_max: float):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

func reparent(source: Node, target: Node) -> void:
	source.get_parent().remove_child(source)
	target.add_child(source)
	source.set_owner(target)
