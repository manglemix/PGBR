class_name AutoGoto
extends Node


signal destination_reached

export var _origin: Vector3
export var _destination: Vector3
export var completion_distance := 2.0
export var enabled := true setget set_enabled
export var turn_head := true

var path: PoolVector3Array

var _optimize := true
onready var _navigation := get_tree().get_current_scene().get_node("Navigation") as Navigation


func _init(from: Vector3, to: Vector3, optimize:=true):
	_origin = from
	_destination = to
	_optimize = optimize


func _ready():
	set_path(_origin, _destination, _optimize)


func set_enabled(value: bool):
	enabled = value
	set_process(value)


func set_path(from: Vector3, to: Vector3, optimize:=true):
	_origin = _navigation.get_closest_point(from)
	_destination = _navigation.get_closest_point(to)
	_optimize = optimize
	
	path = _navigation.get_simple_path(_origin, _destination, _optimize)
	enabled = true


func _process(delta):
	if get_parent().global_transform.origin.distance_to(path[0]) < completion_distance:
		path.remove(0)
		
		if len(path) == 0:
			emit_signal("destination_reached")
			set_enabled(false)
			return
	
	get_parent().global_move_to_vector(path[0])
	
	if turn_head:
		get_parent().global_head_to_vector(path[0])
	
	if Debug.enabled:
		var debug_path := path
		debug_path.insert(0, get_parent().global_transform.origin)
		Debug.draw_points(debug_path)
