class_name AutoGoto
extends Node


signal destination_reached
signal no_path

export var destination: Vector3
export var completion_distance := 2.0
export var enabled := true setget set_enabled
export var turn_head := true
export var safe_distance := 0.5

var path: PoolVector3Array
var _optimize := true
onready var _navigation := get_tree().get_current_scene().get_navigation(self) as Navigation


func _init(to: Vector3, optimize:=true):
	destination = to
	_optimize = optimize


func _ready():
	set_path(destination, _optimize)


func _exit_tree():
	get_parent().stop_moving()


func set_enabled(value: bool):
	enabled = value
	set_process(value)


func set_path(to: Vector3, optimize:=true):
	destination = _navigation.get_closest_point(to)
	_optimize = optimize
	
	path = _navigation.get_simple_path(_navigation.get_closest_point(get_parent().global_transform.origin), destination, _optimize)
	
	if path.empty():
		emit_signal("no_path")
		set_enabled(false)
	else:
		set_enabled(true)


func _process(_delta):
	if get_parent().global_transform.origin.distance_to(path[0]) < completion_distance:
		path.remove(0)
		
		if path.empty():
			emit_signal("destination_reached")
			set_enabled(false)
			return
	
	var collision := get_parent().move_and_collide(path[0] - get_parent().global_transform.origin, true, true, true) as KinematicCollision
	
	if is_instance_valid(collision):
		if path.size() > 1:
			# this pushes the next path away from the parent and the next point
			# if the next point is at a corner, this should end up pushing it away from the corner
			path[0] = _navigation.get_closest_point(path[0] + ((path[0] - get_parent().global_transform.origin).normalized() + (path[0] - path[1]).normalized()) * safe_distance)
	
	get_parent().global_move_to_vector(path[0])
	
	if Debug.enabled:
		var debug_path := path
		debug_path.insert(0, get_parent().global_transform.origin)
		Debug.draw_points(debug_path, Color.black)
