# A streamlined way to manage scenes, multiple cameras, and user input
class_name Director
extends Node


signal player_changed(node)

export var _player_path: NodePath
export var invert_y := false
export var mouse_sensitivity := 0.001
export var jump_buffer := 0.3

var player: Spatial setget set_player


func set_player(node: Spatial):
	if is_instance_valid(player):
		player.user_input = false
	
	player = node
	emit_signal("player_changed", player)
	
	if is_instance_valid(player):
		player.user_input = true


func get_state() -> Dictionary:
	return {
		"player": get_path_to(player),
		"invert_y": invert_y,
		"mouse_sensitivity": mouse_sensitivity,
	}


func set_state(state: Dictionary) -> void:
	set_player(get_node_or_null(state["player"]))
	invert_y = state["invert_y"]
	mouse_sensitivity = state["mouse_sensitivity"]


func _ready():
	if get_child_count() == 0:
		Saves.load_save_data()
	else:
		set_player(get_node_or_null(_player_path))


func get_branch(node: Node) -> Node:
	for child in get_children():
		if child.is_a_parent_of(node):
			return child
	return null


func is_branch(node: Node) -> bool:
	return node in get_children()


func get_navigation(node: Node) -> Navigation:
	return get_branch(node).get_node("Navigation") as Navigation


func camera_raycast(camera: Camera, distance:= 0.0, exclude:= [], screen_point:= get_viewport().size / 2) -> Dictionary:
	if is_zero_approx(distance):
		distance = camera.far
	
	return get_viewport().world.direct_space_state.intersect_ray(camera.global_transform.origin, camera.project_position(screen_point, distance), exclude)


func current_camera_raycast(distance:=0.0, exclude:=[], screen_point:= get_viewport().size / 2) -> Dictionary:
	return camera_raycast(get_viewport().get_camera(), distance, exclude, screen_point)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Saves.update_save_data()
		Saves.write_save_data()
		get_tree().quit()
	
	if event.is_action_pressed("debug"):
		Debug.enabled = not Debug.enabled
