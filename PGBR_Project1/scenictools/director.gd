# A streamlined way to manage scenes, multiple cameras, and user input
class_name Director
extends Node


export var _player_path: NodePath
export var invert_y := false
export var mouse_sensitivity := 0.001

var player: Spatial setget set_player


func _ready():
	set_player(get_node_or_null(_player_path))


func serialize(node: Node) -> Dictionary:
	prints("serializing", node.name, node)
	var cereal := {
		"name": node.name,
		"owner": get_path_to(node.owner),
		"parent": get_path_to(node.get_parent()),
		"class": node.get_class(),
		"groups": node.get_groups(),
		"nodes": [],
		"children": []
	}
	
	# serialize the children; This repeats recursively until there are no children
	for child in node.get_children():
		cereal["children"].append(serialize(child))
	
	# important builtin node variables
	if node is Spatial:
		cereal["global_transform"] = node.global_transform
		cereal["class"] = "Spatial"
	
	if is_instance_valid(node.get_script()):
		var inst_dict := inst2dict(node)
		
		inst_dict.erase("@subpath")	# I found no use for this
		
		# substituting nodes found in the script variables with NodePaths
		for key in inst_dict:
			if inst_dict[key] is Node:
				cereal["nodes"].append(node.get_path_to(inst_dict[key]))
				inst_dict[key] = "nodes@" + str(len(cereal["nodes"]) - 1)
		
		# merging the two dicts
		for key in inst_dict:
			cereal[key] = inst_dict[key]
	
	prints("serialized", node.name)
	return cereal


func deserealize(dict: Dictionary) -> void:
	prints("deserealizing", dict["name"])
	
	dict = dict.duplicate()
	var node := ClassDB.instance(dict["class"]) as Node
	dict.erase("class")
	
	if "@path" in dict:
		node.set_script(load(dict["@path"]))
		dict.erase("@path")
	
	var children := dict["children"] as Array
	dict.erase("children")
	
	var nodes := dict["nodes"] as Array
	dict.erase("nodes")
	
	var parent := dict["parent"] as NodePath
	dict.erase("parent")
	
	get_node(parent).add_child(node)
	node.name = dict["name"]
	dict.erase("name")
	
	for group in dict["groups"]:
		node.add_to_group(group)
	
	# this is also recursive, until the last nodes with no children
	for child in children:
		deserealize(child)
	
	# getting the nodes for the nodes array (originally the elements were NodePaths)
	for i in range(len(nodes)):
		nodes[i] = node.get_node(nodes[i])
	
	# replacing substitutions of nodes in variables (noted by nodes@...) with actual nodes
	for key in dict:
		if dict[key] is String and dict[key].begins_with("nodes@"):
			dict[key] = nodes[int(dict[key].right(6))]
	
	# setting all properties
	for key in dict:
		node.set(key, dict[key])
	
	for child in node.get_children():
		child.request_ready()
	
	node.request_ready()
	
	prints("deserialized", node.name, node)


func save_game(filename: String, key:=OS.get_unique_id()):
	print("saving game, do not exit")
	var file := File.new()
	
	if key.empty():
		file.open(filename, File.WRITE)
	else:
		file.open_encrypted_with_pass(filename, File.WRITE, key)
	
	for node in get_tree().get_nodes_in_group("save_game"):
		file.store_line(to_json(serialize(node)))
	
	file.close()
	print("game saved")


func load_game(filename: String, key:=OS.get_unique_id()):
	var file := File.new()
	
	if key.empty():
		file.open(filename, File.READ)
	else:
		file.open_encrypted_with_pass(filename, File.READ, key)
	
	while not file.eof_reached():
		var line := file.get_line()
		if line.empty():
			break
		deserealize(parse_json(line))
	
	file.close()


func set_player(node: Spatial):
	if is_instance_valid(player):
		player.user_input = false
	
	player = node
	$HUD.set_player(player)
	
	if is_instance_valid(player):
		player.user_input = true


func get_branch(node: Node) -> Node:
	for child in get_children():
		if child.is_a_parent_of(node):
			return child
	return null


func get_navigation(node: Node) -> Navigation:
	return get_branch(node).get_node("Navigation") as Navigation


func camera_raycast(camera: Camera, distance:= 0.0, exclude:= [], screen_point:= get_viewport().size / 2) -> Dictionary:
	if is_zero_approx(distance):
		distance = camera.far
	
	return get_viewport().world.direct_space_state.intersect_ray(camera.global_transform.origin, camera.project_position(screen_point, distance), exclude)


func current_camera_raycast(distance:=0.0, exclude:=[], screen_point:= get_viewport().size / 2) -> Dictionary:
	return camera_raycast(get_viewport().get_camera(), distance, exclude, screen_point)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event.is_action_pressed("debug"):
		Debug.enabled = not Debug.enabled
