extends Area


enum {DETECTED, CLOSE}


func get_proximities() -> Dictionary:
	var bodies := {}
		
	for body in get_overlapping_bodies():
		bodies[body] = DETECTED
	
	for body in $Close.get_overlapping_bodies():
		bodies[body] = CLOSE
	
	return bodies
