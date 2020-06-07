extends KinematicBody


export var acceleration := 10.0
export var fuel_time := 3.0
export var glide_time := 5.0
export var turn_speed := 6.0
export var inertia := 6.0

var speed := 0.0
var vertical_speed := 0.0
var linear_velocity: Vector3

onready var _current_scene := get_tree().get_current_scene()


func _physics_process(delta):
	var tmp_transform := global_transform.looking_at(_current_scene.player.global_transform.origin, Vector3.UP)
	global_transform = global_transform.interpolate_with(tmp_transform, turn_speed * delta)
	
	if fuel_time > 0:
		speed += acceleration * delta
		fuel_time -= delta
	
	elif glide_time <= 0:
		vertical_speed += ProjectSettings.get_setting("physics/3d/default_gravity") * delta
		global_transform.origin.y -= vertical_speed * delta
		if move_and_collide((Vector3(0, - vertical_speed, 0) + linear_velocity) * delta):
			queue_free()
		return
	
	else:
		glide_time -= delta
	
	linear_velocity = linear_velocity.linear_interpolate(global_transform.basis.z * - speed, inertia * delta)
	if move_and_collide(linear_velocity * delta):
		queue_free()
