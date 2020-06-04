extends Area


signal detected
signal body_nearby


enum {DETECTED, NEARBY}


func _ready():
	connect("body_entered", self, "emit_signal", ["detected"])
	$Close.connect("body_entered", self, "emit_signal", ["body_nearby"])


func get_nearby_bodies() -> Array:
	return $Close.get_overlapping_bodies()


func get_proximities() -> Dictionary:
	var bodies := {}
		
	for body in get_overlapping_bodies():
		bodies[body] = DETECTED
	
	
	for body in $Close.get_overlapping_bodies():
		bodies[body] = NEARBY
	
	return bodies
