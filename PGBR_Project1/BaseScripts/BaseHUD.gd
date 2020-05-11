extends Control


export(Array, NodePath) var health_nodes := []	# a list of nodes that need to have methods connected to the player
export(Array, NodePath) var stamina_nodes := []	# a list of nodes that need to have methods connected to the player

var player setget set_player


func _ready():
	get_tree().get_current_scene().connect("player_changed", self, "set_player")


func set_player(node):
	if is_instance_valid(player):
		for node_path in health_nodes:
			player.disconnect("update_health", get_node(node_path), "_on_health_updated")
			player.disconnect("update_max_health", get_node(node_path), "_on_max_health_updated")
	
		for node_path in stamina_nodes:
			player.disconnect("update_stamina", get_node(node_path), "_on_stamina_updated")
			player.disconnect("update_max_stamina", get_node(node_path), "_on_max_stamina_updated")
	
	player = node
	
	for node_path in health_nodes:
		player.connect("update_health", get_node(node_path), "_on_health_updated")
		player.connect("update_max_health", get_node(node_path), "_on_max_health_updated")
	
	for node_path in stamina_nodes:
		player.connect("update_stamina", get_node(node_path), "_on_stamina_updated")
		player.connect("update_max_stamina", get_node(node_path), "_on_max_stamina_updated")
