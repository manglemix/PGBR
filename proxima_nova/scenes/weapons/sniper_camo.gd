extends Weapon

export var fire_range := 100

func _ready():
	self.raycast.cast_to = Vector3(0, 0, -fire_range)
	self.clip_size = 5
	self.fire_rate = 1.0
	self.total_ammo = 3
	self.weapon_name = "Sniper Camo"
	self.is_gun = true
	self.reload_rate = 5.0
