extends Weapon

export var fire_range := 100

func _ready():
	self.raycast.cast_to = Vector3(0, 0, -fire_range)
	self.clip_size = 8
	self.fire_rate = 0.2
	self.total_ammo = 100
	self.weapon_name = "Pistol"
	self.is_gun = true
	self.reload_rate = 1.0
