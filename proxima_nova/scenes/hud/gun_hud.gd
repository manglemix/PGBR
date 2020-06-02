extends VBoxContainer


onready var gun_label := $Gun/GunContainer/GunLabel as Label
onready var current_ammo_label := $AmmoHud/Container/CurrentAmmo/CurrentAmmo as Label
onready var total_ammo_label := $AmmoHud/Container/TotalAmmo/TotalAmmo as Label
onready var reloading := $Reloading as VBoxContainer
onready var reloading_txt := $Reloading/ReloadingText as Label
onready var reload_tween := $Reloading/ReloadTween as Tween
onready var reloading_bar := $Reloading/ReloadingBar as TextureProgress
onready var player := get_tree().get_root().find_node("Player", true, false) as Player
onready var hand := player.find_node("HandTrigger", true, false)


func _ready():
	player.connect("weapon_switch", self, "_weapon_switched")
	_weapon_switched()


func _process(delta) -> void:
	pass


func _weapon_switched() -> void:
	var gun
	if hand.get_child_count() > 0:
		gun = hand.get_child(0)
	if gun is Weapon and gun.is_gun:
		gun.connect("reloading", self, "_reloading")
		gun.connect("current_ammo", self, "_current_ammo")
		gun.connect("total_ammo", self, "_total_ammo")
		gun.connect("out_of_ammo", self, "_out_of_ammo")
		
		_current_ammo(gun.current_ammo)
		_total_ammo(gun.total_ammo)
		gun_label.set_text(gun.weapon_name)
		
		if gun.total_ammo > 0:
			reloading.visible = false
	else:
		_current_ammo(0)
		_total_ammo(0)
		gun_label.set_text("")


func _reloading(check: bool, reload_time: float) -> void:
	if check:
		reloading_txt.set_text("Reloading...")
		reloading.visible = true
		print("reload_time: ", reload_time)
		reload_tween.interpolate_property(reloading_bar, "value", 0, 100, reload_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		reload_tween.start()
	else:
		reloading.visible = false


func _current_ammo(current_ammo: int) -> void:
	current_ammo_label.set_text("%02d" % [current_ammo])


func _total_ammo(total_ammo: int) -> void:
	total_ammo_label.set_text("%04d" % [total_ammo])


func _out_of_ammo() -> void:
	reloading_txt.set_text("Out of Ammo!")
	reloading.visible = true
	reloading_bar.value = 0
