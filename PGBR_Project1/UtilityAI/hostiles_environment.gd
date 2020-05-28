class_name HostilesEnvironment
extends Maximiser

# this is an example of a virtual environment node
# a virtual environment is a maximiser with methods and variables prepared for its children to use


export var hostile_groups: PoolStringArray

var dont_save := ["hostile_nodes"]
var hostile_nodes := []


func _ready():
	connect("calling_get_score", self, "update_hostile_nodes")


func update_hostile_nodes(_employee):
	hostile_nodes.clear()
	for group in hostile_groups:
		for enemy in get_tree().get_nodes_in_group(group):
			hostile_nodes.append(enemy)
