extends Weapon

export var fire_range := 100

func _ready():
	self.raycast.cast_to = Vector3(0, 0, -fire_range)
	self.total_ammo = 300
	self.weapon_name = "Flame Thrower"
	self.is_gun = true
