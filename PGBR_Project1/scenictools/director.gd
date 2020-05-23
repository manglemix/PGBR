# A streamlined way to manage scenes, multiple cameras, and user input
class_name Director
extends Node



export var _player_path: NodePath
export var invert_y := false
export var mouse_sensitivity := 0.001

var player: Spatial setget set_player


func _ready():
	set_player(get_node_or_null(_player_path))


func set_player(node: Spatial):
	if is_instance_valid(player):
		player.user_input = false
	
	player = node
	$HUD.set_player(player)
	
	if is_instance_valid(player):
		player.user_input = true


func get_branch(node: Node) -> Node:
	for child in get_children():
		if child.is_a_parent_of(node):
			return child
	return null


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
		get_tree().quit()
	
	if event.is_action_pressed("debug"):
		Debug.enabled = not Debug.enabled
