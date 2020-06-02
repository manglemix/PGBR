tool
extends DirectionalLight

export var day_cycle := 60 setget _set_day_cycle
export var dawn := Color(0.8,0.6,0.2) setget _set_dawn
export var midday := Color(0.8,0.8,0.6) setget _set_midday
export var evening := Color(0.8,0.4,0.3) setget _set_evening
export var night := Color(0.4,0.2,0.8) setget _set_night
export var sky_color := Color(0.0,0.3,1.0) setget _set_sky_color


var day_quadrant := 0
var curr_tick := 0.0
var rot_speed := 0.0
var curr_color: Color
onready var sky := $Sky as WorldEnvironment


func _set_day_cycle(val: int) -> void:
	day_cycle = val


func _set_dawn(val: Color) -> void:
	dawn = val


func _set_midday(val: Color) -> void:
	midday = val


func _set_evening(val: Color) -> void:
	evening = val


func _set_night(val: Color) -> void:
	night = val


func _set_sky_color(val: Color) -> void:
	sky_color = val


func rotate_light(delta: float) -> void:
	rotate_x(-rot_speed * delta)


func set_light_color() -> void:
	var mix := abs(sin(rotation.x))
	match day_quadrant:
		0:
			curr_color = lerp(dawn, midday, mix) as Color
		1:
			curr_color = lerp(evening, midday, mix) as Color
		2:
			curr_color = lerp(evening, night, mix)
		3:
			curr_color = lerp(dawn, night, mix)
	light_color = curr_color


func set_sky_adjustments() -> void:
	if sky == null:
		return;
	if sky.environment.background_mode == Environment.BG_COLOR:
		sky.environment.background_color = lerp(sky_color, curr_color, 0.45)
		sky.environment.ambient_light_color = sky.environment.background_color
	if sky.environment.fog_enabled == true:
		sky.environment.fog_color = sky.environment.background_color


func _ready() -> void:
	rot_speed = (2.0 * PI) / day_cycle
	rotation.x = 0.0
	rotation.y = 0.0
	rotation.z = 0.0
	curr_color = dawn
	light_color = curr_color
	day_quadrant = 0
	curr_tick = 0.0
	
	if sky.environment.background_mode == Environment.BG_COLOR:
		sky.environment.background_color = sky_color


func _process(delta: float) -> void:
	rotate_light(delta)
	set_light_color()
	set_sky_adjustments()
	curr_tick += delta
	
	if rotation.x < 0 and rotation.x > -PI/2.0:
		day_quadrant = 0
	elif rotation.x < -PI/2.0 and rotation.x > -PI:
		day_quadrant = 1
	elif rotation.x < PI and rotation.x > PI/2.0:
		day_quadrant = 2
	else:
		day_quadrant = 3
	
	if curr_tick > day_cycle:
		curr_tick = 0.0


