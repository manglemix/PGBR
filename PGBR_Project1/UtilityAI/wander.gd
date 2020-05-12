class_name Wander
extends Action


export var max_distance := 10.0
export var min_distance := 5.0

onready var scene = get_tree().get_current_scene()


func get_score(employee) -> float:
	if len(get_action_tree().opponent_nodes) == 0:
		return INF
	return 0.0


func get_action(employee) -> Reference:
	randomize()
	return WanderAction.new(employee, max_distance, min_distance, scene)


class WanderAction:
	var employee
	var path: PoolVector3Array
	var max_distance: float
	var min_distance: float
	var goto
	var scene
	
	func _init(node, max_distance: float, min_distance: float, scene):
		employee = node
		self.max_distance = max_distance
		self.min_distance = min_distance
		self.scene = scene
	
	func process(_delta) -> int:
		if is_instance_valid(goto):
			if not goto.process():
				goto = null
		else:
			goto = scene.get_node("Navigation").auto_goto(employee, Vector3.BACK.rotated(Vector3.UP, rand_range(0, TAU)) * rand_range(min_distance, max_distance))
		
		return 1		# CAN_CHANGE
	
	func end() -> void:
		return
