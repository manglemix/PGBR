extends Navigation


func get_global_path(start: Vector3, end: Vector3, optimize:=true):
	# Finds the closest point to the start and end and returns the simple path between
	start = get_closest_point(start)
	end = get_closest_point(end)
	
	return get_simple_path(start, end, optimize)


func auto_goto(node, destination: Vector3) -> AutoGoto:
	# an easier way to construct an AutoGoto
	return AutoGoto.new(node, get_global_path(node.global_transform.origin, destination, true))


class AutoGoto:
	# autopilots the node given to follow the path given
	var node
	var path: PoolVector3Array
	
	func _init(node, path: PoolVector3Array):
		self.node = node
		self.path = path
	
	func process() -> bool:
		# returns true if still working, false if done and should be deleted
		if node.global_transform.origin.distance_to(path[0]) < 2.0:
			path.remove(0)
		
		if len(path) == 0:
			return false
		
		node.global_move_to_vector(path[0])
		node.global_head_to_vector(path[0])
		
		if Debug.enabled and len(path) > 0:
			var debug_path := path
			debug_path.insert(0, node.global_transform.origin)
			Debug.draw_points(debug_path)
		
		return true
