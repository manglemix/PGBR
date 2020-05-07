class_name BaseGun
extends Spatial


func _ready():
	get_parent().connect("shoot", self, "shoot")


func shoot():
	pass
