# A streamlined way to manage scenes, multiple cameras, and user input
extends Node


var invert_y := false
var mouse_sensitivity := 0.001
var player: Node setget set_player


func set_player(node: Node):
	if is_instance_valid(player):
		player.user_input = false
	
	player = node
	player.user_input = true


func camera_raycast(camera: Camera, distance := 0.0, exclude := [], screen_point := get_viewport().size / 2) -> Dictionary:
	if is_zero_approx(distance):
		distance = camera.far
	
	return get_viewport().world.direct_space_state.intersect_ray(camera.global_transform.origin, camera.project_position(screen_point, distance), exclude)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("debug"):
		Debug.enabled = not Debug.enabled
