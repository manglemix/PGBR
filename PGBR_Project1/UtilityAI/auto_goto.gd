class_name AutoGoto
extends Node


signal destination_reached

export var origin: Vector3 setget set_origin
export var destination: Vector3 setget set_destination
export var completion_distance := 2.0
export var enabled := true setget set_enabled
export var turn_head := true

var path: PoolVector3Array


func _ready():
	set_path(origin, destination)


func set_enabled(value: bool):
	enabled = value
	set_process(value)


func set_origin(position: Vector3):
	origin = position
	set_path(position, destination)


func set_destination(position: Vector3):
	destination = position
	set_path(origin, position)


func set_path(from: Vector3, to: Vector3, optimize:=true):
	origin = from
	destination = to
	
	path = get_tree().get_current_scene().get_node("Navigation").get_global_path(from, to, optimize)
	enabled = true


func _process(delta):
	if get_parent().global_transform.origin.distance_to(path[0]) < completion_distance:
		path.remove(0)
		
		if len(path) == 0:
			emit_signal("destination_reached")
			enabled = false
			return
	
	get_parent().global_move_to_vector(path[0])
	
	if turn_head:
		get_parent().global_head_to_vector(path[0])
	
	if Debug.enabled:
		var debug_path := path
		debug_path.insert(0, get_parent().global_transform.origin)
		Debug.draw_points(debug_path)
