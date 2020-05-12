class_name Wander
extends State


export var min_distance := 5.0
export var max_distance := 10.0


func _process(delta):
	var goto := get_parent().get_node_or_null("Goto") as AutoGoto
	
	if not is_instance_valid(goto):
		goto = AutoGoto.new(get_parent().global_transform.origin,
		get_parent().global_transform.origin + Vector3.BACK.rotated(Vector3.UP, rand_range(0, TAU)) * rand_range(min_distance, max_distance))
		
		get_parent().add_child(goto)
		goto.name = "Goto"
		goto.connect("destination_reached", goto, "queue_free")
