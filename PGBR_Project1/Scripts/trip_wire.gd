extends RayCast


signal body_entered(body)
signal body_exited(body)

var _last_collision: PhysicsBody


func get_collision_point_or_end():
	# returns a collision point, or the point at the end of the RayCast if there was no collision
	if is_instance_valid(get_collider()):
		return get_collision_point()
	else:
		return to_global(cast_to)


func _physics_process(delta):
	if get_collider() != _last_collision:
		if is_instance_valid(get_collider()):
			_last_collision = get_collider()
			emit_signal("body_entered", _last_collision)
		else:
			emit_signal("body_exited", _last_collision)
			_last_collision = null		# sometimes Deleted Object can be invalid, but we dont want to set _last_collision to that
