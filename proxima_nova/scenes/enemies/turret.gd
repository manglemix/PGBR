extends Spatial


export var target_hitbox := "BodyHitbox"
export var raise_speed := 6.0

onready var _current_scene := get_tree().get_current_scene()


func _process(delta):
	$Turret.global_turn_to_vector(_current_scene.player.get_node(target_hitbox).global_transform.origin)
	if $Turret/Gun.clip_ammo == 0:
		$Turret/Gun.reload()
	
	if $Turret/Gun.collide_all() == _current_scene.player:
		$Turret.transform.origin.y = lerp($Turret.transform.origin.y, 0.9, 6.0 * delta)
		$Turret/Gun.shoot()
	
	else:
		$Turret.transform.origin.y = lerp($Turret.transform.origin.y, 0, 6.0 * delta)
