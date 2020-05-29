extends Node


var saves_paths: PoolStringArray
var master_config: Dictionary

var _directory := Directory.new()
var _hierarchies: Array
var _states: Array
var _director_state: Dictionary


func _ready():
	_directory.open("res://")
	if _directory.file_exists("master_config.ini"):
		var file := File.new()
		file.open("master_config.ini", File.READ)
		master_config = parse_json(file.get_line())
		file.close()

	_directory.list_dir_begin(true, true)

	while true:
		var filename = _directory.get_next()
		if filename.empty():
			break
		
		if filename.ends_with(".save"):
			saves_paths.append(filename.trim_suffix(".save"))


func write_save_data(name:="save1") -> int:
	# stores the current save data to the computer
	var save := File.new()
	var err := save.open(name + ".save", File.WRITE)
	
	if err != OK:
		return err
	
	save.store_var({
		"hierarchies": _hierarchies,
		"states": _states,
		"director_state": _director_state
	})
	
	save.close()
	
	return OK


func read_save_data(name:="save1") -> int:
	# reads save data from a file with the save name given
	var save := File.new()
	var err := save.open(name + ".save", File.READ)

	if err != OK:
		return err

	var data := save.get_var() as Dictionary
	save.close()
	
	_hierarchies = data["hierarchies"]
	_states = data["states"]
	_director_state = data["director_state"]

	return OK


func load_save_data() -> int:
	# adds the saved hierarchies and states into the current scene
	var director := get_tree().get_current_scene() as Node
	
	for i in range(len(_hierarchies)):
		var result := load_hierarchy(_hierarchies[i])
		set_state(result[0], _states[i])
		director.get_node(result[1]).add_child(result[0])
	
	director.set_state(_director_state)
	return OK


func update_save_data():
	# creates new save data from the current scene
	_hierarchies.clear()
	_states.clear()
	_director_state = get_tree().get_current_scene().get_state()
	
	for child in get_tree().get_current_scene().get_children():
		_hierarchies.append(get_hierarchy(child))
		_states.append(get_state(child))


func get_state(owner: Node) -> Dictionary:
	# stores all the variables of a tree of nodes with the owner being the root node
	var states := {}
	var nodes = _get_family(owner)

	nodes.insert(0, owner)

	for node in nodes:
		# if a node or its owner is in the group 'ignore_state', the state will not be stored
		if node.is_in_group("ignore_state"):
			continue

		elif is_instance_valid(node.owner) and node.owner.is_in_group("ignore_state"):
			continue
		
		if node.has_method("_override_save"):
			var current_state := node._override_save() as Dictionary
			if not current_state.empty():
				states[owner.get_path_to(node)] = current_state
			continue
		
		if node.has_method("_saving_state"):
			node._saving_state()
		
		var current_state := {}
		
		var groups := node.get_groups() as Array
		if not groups.empty():
			current_state["groups"] = groups

		# store script variables
		if is_instance_valid(node.get_script()):
			merge_dicts(current_state, inst2dict(node))
			current_state.erase("@subpath")		# useless variables generated by inst2dict
			current_state.erase("@path")
			
			# used to omit some variables from being saved
			if "dont_save" in current_state:
				for name in current_state["dont_save"]:
					current_state.erase(name)
				current_state.erase("dont_save")

		# important builtin node variables
		if node is Spatial:
			current_state["transform"] = node.transform

		if not current_state.empty():
			states[owner.get_path_to(node)] = current_state

	return states


func get_hierarchy(owner: Node, ignore_foreign:=true) -> Dictionary:
	# converts a tree of nodes (with the root node being the owner) into a dict of paths to PackedScenes
	# cannot compensate for individual nodes added through code
	var children = _get_family(owner)
	var scene := get_tree().get_current_scene()

	assert(not owner.filename.empty())
	var scenes := {str(scene.get_path_to(owner)): owner.filename}

	for child in children:
		# if the node doesn't have an owner, it is loaded dynamically and thus wont be saved
		# if the node's owner is the current scene, it is not a part of another PackedScene, and should therefore be recorded
		if not is_instance_valid(child.owner) or child.owner == scene:
			if child.filename.empty():
				# if it wasn't loaded from a PackedScene, the nodes were added individually (which we can't replicate)
				if not ignore_foreign:
					printerr(str(child) + " was not loaded from a scene")
					assert(false)
			else:
				# if there is a filename, it was loaded from a PackedScene
				scenes[str(owner.get_path_to(child))] = child.filename

	return scenes


func load_hierarchy(dict: Dictionary) -> Array:
	# converts a dict of paths to PackedScenes into a tree of nodes
	# returns an array of two elements, the first being the root node
	# the second being the rightful parent of the root
	var root: Node
	var root_parent: String

	for path in dict:
		var node := load(dict[path]).instance() as Node
		var parent: String
		
		if "/" in path:
			var last_idx := path.find_last("/") as int
			parent = path.left(last_idx)
			node.name = path.right(last_idx)

		else:
			# if there are no slashes, the path itself is the name of the node
			# and the parent should be the root node
			parent = "."
			node.name = path
		
		if root_parent.empty():
			# the first node in the dict is the root node
			# the parent for the first node in the dict is relative to the current scene
			root_parent = parent
			root = node
		
		else:
			root.get_node(parent).add_child(node)

	return [root, root_parent]


func set_state(owner: Node, dict: Dictionary) -> void:
	# applies the state given onto owner and its family
	dict = dict.duplicate()
	var nodes = _get_family(owner)
	nodes.insert(0, owner)

	for path in dict:
		var current_state := dict[path] as Dictionary
		var node := owner.get_node(path)

		if node.has_method("_override_load"):
			node._override_load(current_state)
			continue

		if node.has_method("_loading_state"):
			node._loading_state()

		if "groups" in current_state:
			# this is also recursive, until the last nodes with no children
			for group in current_state["groups"]:
				node.add_to_group(group)
			current_state.erase("groups")

		# setting all properties
		for key in current_state:
			node.set(key, current_state[key])


static func _get_family(owner: Node) -> Array:
	# returns an array of all descendents of the owner given
	var children := owner.get_children()

	for child in owner.get_children():
		children += _get_family(child)

	return children


static func merge_dicts(dict1: Dictionary, dict2: Dictionary):
	# merges the second dict into the first dict
	for key in dict2:
		dict1[key] = dict2[key]