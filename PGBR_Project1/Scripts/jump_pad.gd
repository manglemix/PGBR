class_name JumpPad
extends Area


export var horizontal_distance := 320.0
export var air_time := 5.0


func _ready():
	connect("body_entered", self, "jump")


func jump(node):
	if node is StaticBody:
		return
	
	node.linear_velocity = global_transform.basis.z * horizontal_distance / air_time
	node.linear_velocity.y = ProjectSettings.get_setting("physics/3d/default_gravity") * air_time / 2
