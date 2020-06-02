extends Weapon

export var fire_range := 100
onready var muzzle_flash := $MuzzleFlash as MuzzleFlash

func _ready():
	self.raycast.cast_to = Vector3(0, 0, -fire_range)
	self.clip_size = 16
	self.fire_rate = 0.1
	self.total_ammo = 220
	self.weapon_name = "Uzi Gold"
	self.is_gun = true
	self.reload_rate = 3.0


func fire() -> void:
	.fire()
	muzzle_flash.muzzle_flash()
