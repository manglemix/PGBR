class_name JumpPad
extends Area


export var horizontal_distance := 320.0
export var air_time := 5.0
export var new_branch_path: String
export var scene_transform := Transform.IDENTITY


func jump(node):
	node.linear_velocity = global_transform.basis.z * horizontal_distance / air_time * 1.2
	node.linear_velocity.y = ProjectSettings.get_setting("physics/3d/default_gravity") * air_time / 2
	
	if not new_branch_path.empty():
		var new_transform := scene_transform
		new_transform.origin += global_transform.basis.z * horizontal_distance + global_transform.origin
		var timer := Timer.new()
		timer.connect("timeout", self, "load_branch", [node, new_transform])
		add_child(timer)
		timer.start(air_time / 2)


func load_branch(persistent_node: Spatial, new_transform: Transform):
	print_debug("loading " + new_branch_path)
	var scene := load(new_branch_path).instance() as Node
	
	var org_transform := persistent_node.global_transform
	persistent_node.get_parent().remove_child(persistent_node)
	get_tree().get_current_scene().get_branch(self).queue_free()
	get_tree().get_current_scene().add_child(scene)
	scene.global_transform = new_transform
	scene.add_child(persistent_node)
	persistent_node.global_transform = org_transform
	
	print_debug("finished loading " + new_branch_path)
