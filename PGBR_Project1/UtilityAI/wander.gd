class_name Wander
extends Action


export var max_distance := 10.0
export var min_distance := 5.0

onready var scene = get_tree().get_current_scene()
var path: PoolVector3Array


func get_score() -> float:
	if len(get_tree().get_nodes_in_group("Friendly")) == 0:
		return INF
	return 0.0


func execute() -> int:
	if len(path) == 0:
		var destination = employee.global_transform.basis.z.rotated(Vector3.UP, rand_range(0, TAU)) * rand_range(min_distance, max_distance)
		destination += employee.global_transform.origin
		destination = scene.get_node("Navigation").get_closest_point(destination)
		
		path = scene.get_node("Navigation").get_simple_path(scene.get_node("Navigation").get_closest_point(employee.global_transform.origin), destination)
	
	employee.move_to_vector(path[0] - employee.global_transform.origin)
	employee.global_head_to_vector(path[0])
	
	if employee.global_transform.origin.distance_to(path[0]) < 0.5:
		path.remove(0)
	
	if len(path) > 1:
		Debug.draw_points(path)
	
	return CAN_CHANGE
