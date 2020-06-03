# For weapons which use bullets and have reload times
class_name BallisticGun
extends Hitscan


signal total_ammo_changed(total_ammo)
signal clip_size_changed(clip_size)
signal clip_ammo_changed(clip_ammo)
signal reloading
signal reloaded

export var total_ammo: int setget set_total_ammo
export var clip_size: int setget set_clip_size
export var clip_ammo: int setget set_clip_ammo
export var reload_time: float


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


func reload() -> void:
	if clip_ammo == clip_size:
		return
	
	emit_signal("reloading")
	var timer = get_tree().create_timer(reload_time)
	# let the timer emit the signal "reloaded" for us
	timer.connect("timeout", self, "emit_signal", ["reloaded"])
