# this node is to hide assistant nodes which should only be visible in the editor
extends Spatial


export var hide_on_entry := true		# if true, this node will hide when entering the tree
export var free_on_entry := false		# if true, this node will queue_free when entering the tree


func _enter_tree():
	if free_on_entry:
		queue_free()
	
	elif hide_on_entry:
		hide()
