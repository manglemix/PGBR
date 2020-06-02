extends Node

class Activation:
	var function
	var dFunction
	var name

func sigmoid(x: float, derivative: bool) -> float:
	if derivative:
		return x * (1 - x)
	return 1 / (1 + exp(-1 * x))
