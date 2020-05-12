class_name NavigationPlus
extends Navigation


func get_global_path(start: Vector3, end: Vector3, optimize:=true):
	# Finds the closest point to the start and end and returns the simple path between
	start = get_closest_point(start)
	end = get_closest_point(end)
	
	return get_simple_path(start, end, optimize)
