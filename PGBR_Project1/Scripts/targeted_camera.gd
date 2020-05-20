class_name TargetedCamera
extends Camera


signal reached_target

export var target_path := NodePath()
export var interpolation_speed := 12.0
export var lock_on_arrival := true

var target: Spatial setget set_target
var _arrived := false


func _init(node: Spatial):
	target = node
	target_path = NodePath()


func _ready():
	if not target_path.is_empty():
		target = get_node(target_path)


func set_target(node: Spatial):
	target = node
	_arrived = false


func _process(delta):
	if lock_on_arrival and _arrived:
		global_transform = target.global_transform
		return
	
	global_transform = global_transform.interpolate_with(target.global_transform, interpolation_speed * delta)
	
	if target is Camera:
		fov += (target.fov - fov) * interpolation_speed * delta
	
	if global_transform.origin.distance_to(target.global_transform.origin) <= 0.01:
		emit_signal("reached_target")
		_arrived = true
