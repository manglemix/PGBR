extends Area


signal detected			# emitted when an object enters the outer collision shape
signal body_nearby		# emitted when an object enters the inner collision shape


enum {DETECTED, NEARBY}


func _ready():
	connect("body_entered", self, "emit_signal", ["detected"])
	$Close.connect("body_entered", self, "emit_signal", ["body_nearby"])


func get_nearby_bodies() -> Array:
	# returns the overlapping bodies within the inner collision shape
	return $Close.get_overlapping_bodies()


func get_proximities() -> Dictionary:
	# Returns a dict where the keys are overlapping bodies and the items are enums corresponding to distance
	var bodies := {}
		
	for body in get_overlapping_bodies():
		bodies[body] = DETECTED
	
	
	for body in $Close.get_overlapping_bodies():
		bodies[body] = NEARBY
	
	return bodies
