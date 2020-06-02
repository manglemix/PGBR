# hides or shows a parent if this node is visible
class_name ChunkHider
extends VisibilityNotifier


func _ready():
	connect("screen_entered", get_parent(), "show")
	connect("screen_exited", get_parent(), "hide")
