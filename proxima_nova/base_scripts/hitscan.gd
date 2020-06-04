class_name Hitscan
extends Spatial


signal shooting		# emitted before a shot is checked and fired
signal shot			# emitted when a shot is fired

export var _raycast_path := NodePath("Muzzle")
export var clipping_distance := 1000.0 setget set_clipping_distance

var dont_save := ["_player", "handles", "_raycast"]
var can_fire := true


onready var _raycast := get_node(_raycast_path) as RayCast


func _ready():
	set_clipping_distance(clipping_distance)


func set_clipping_distance(distance: float) -> void:
	if not is_instance_valid(_raycast):
		return
	
	assert(distance > 0)
	clipping_distance = distance
	_raycast.cast_to = _raycast.cast_to.normalized() * distance


func aim_towards(target: Vector3) -> void:
	get_parent().look_at(target, Vector3.UP)
	get_parent().rotate_object_local(Vector3.UP, PI)


func get_collider():
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = true
	_raycast.force_raycast_update()
	return _raycast.get_collider()


func shoot() -> bool:
	emit_signal("shooting")
	if not can_fire:
		return false
	
	_raycast.collide_with_areas = true
	_raycast.collide_with_bodies = false
	_raycast.force_raycast_update()
	var node = _raycast.get_collider()
	
	if is_instance_valid(node):
		if node.has_method("damage"):
			node.damage(self)
		
	else:
		_raycast.collide_with_areas = false
		_raycast.collide_with_bodies = true
		_raycast.force_raycast_update()
		var node2 = _raycast.get_collider()
		
		if is_instance_valid(node2) and node2.has_method("damage"):
			node2.damage(self)
	
	Debug.draw_dot(_raycast.get_collision_point(), Color.red)
	emit_signal("shot")
	return true
