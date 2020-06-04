# For weapons which use bullets and have reload times
class_name BallisticGun
extends Hitscan


signal total_ammo_changed(total_ammo)
signal clip_size_changed(clip_size)
signal clip_ammo_changed(clip_ammo)
signal reloading
signal reloaded

export var total_ammo: int setget set_total_ammo	# the total amount of ammo available to be put into a clip
export var clip_size: int setget set_clip_size		# the maximum number of bullets in a clip
export var clip_ammo: int setget set_clip_ammo		# the current number of bullets in the clip
export var reload_time: float						# time needed to reload in seconds

var _last_shot_time: int	# the last system time in msecs when the gun shot


func set_total_ammo(value: int):
	assert(value >= 0)
	total_ammo = value
	emit_signal("total_ammo_changed", total_ammo)
	
	if total_ammo < clip_ammo:
		set_clip_ammo(total_ammo)


func set_clip_size(value: int):
	clip_size = value
	emit_signal("clip_size_changed", clip_size)


func set_clip_ammo(value: int):
	assert(value >= 0)
	clip_ammo = value
	emit_signal("ammo_changed", clip_ammo)


func _ready():
	connect("shooting", self, "decrement_clip")


func reload() -> bool:
	if clip_ammo == clip_size or total_ammo == 0:
		return false
	
	emit_signal("reloading")
	var timer = get_tree().create_timer(reload_time)
	timer.connect("timeout", self, "_reload_clip")
	return true


func _reload_clip() -> void:
	if total_ammo >= clip_size:
		clip_ammo = clip_size
		total_ammo -= clip_size
	
	else:
		clip_ammo = total_ammo
		total_ammo = 0
	
	emit_signal("reloaded")


func decrement_clip() -> void:
	if (OS.get_system_time_msecs() - _last_shot_time) / 1000 >= reload_time and clip_ammo > 0:
		clip_ammo -= 1
		_last_shot_time = OS.get_system_time_msecs()
		can_fire = true
		
	can_fire = false
