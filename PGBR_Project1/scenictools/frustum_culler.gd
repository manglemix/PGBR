# this node will hide other nodes within the group given if those nodes were not on screen
class_name FrustumCuller
extends Node


export var group_name := "frustum_cull"		# the name of the group in which nodes will be hidden when out of view
export var buffer := 20.0 					# the extra pixels from the screen edge at which objects will be hidden
export var min_distance := 10.0				# nodes closer than this will always be visible
export var max_distance := 20.0				# nodes furhter than this will always be hidden
export var update_msecs := 42		# the duration of a frame, in which frustum culling is done (the default value is for 24 fps)

var _thr := Thread.new()

onready var _screen_size := get_viewport().size


func _ready():
	_thr.start(self, "cull")


func cull(userdata):
	while true:
		var camera := get_viewport().get_camera()
		
		for node in get_tree().get_nodes_in_group(group_name):
			var distance := camera.global_transform.origin.distance_to(node.global_transform.origin)
			 
			if distance < min_distance:
				node.show()
			
			elif distance > max_distance:
				node.hide()
			
			elif camera.is_position_behind(node.global_transform.origin):
				node.hide()
			
			else:
				var point := camera.unproject_position(node.global_transform.origin)
				if point.x < - buffer or point.y < - buffer or point.x > _screen_size.x + buffer or point.y > _screen_size.y + buffer:
					node.hide()
				
				else:
					node.show()
		
		OS.delay_msec(update_msecs)
