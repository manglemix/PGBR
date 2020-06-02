extends Node

class_name Weapon

signal reloading(check)
signal current_ammo(ammo)
signal total_ammo(ammo)
signal out_of_ammo

export var fire_rate := 0.5
export var clip_size := 5
export var reload_rate := 1.0
export var weapon_name := "Weapon"
export var is_gun := false


onready var raycast := $"../../../../Head/Camera/WeaponRayCast" as RayCast


var current_ammo := 0 setget _set_current_ammo
var total_ammo := 120 setget _set_total_ammo
var can_fire := true
var reloading := false


func _set_current_ammo(val: int) -> void:
	if val <= 0:
		current_ammo = 0
	else:
		current_ammo = val
	emit_signal("current_ammo", current_ammo)


func _set_total_ammo(val: int) -> void:
	if val <= 0:
		total_ammo = 0
	else:
		total_ammo = val
	emit_signal("total_ammo", total_ammo)


func _ready() -> void:
	emit_signal("current_ammo", self.current_ammo)
	emit_signal("total_ammo", self.total_ammo)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("primary_fire") and can_fire:
		if self.current_ammo > 0 and not reloading:
			fire()
		elif not reloading:
			reload()
	
	if Input.is_action_just_pressed("reload") and not reloading:
		reload()


func check_collision() -> void:
	if raycast.is_colliding():
		var collider := raycast.get_collider()
		if collider.is_in_group("Enemies"):
			collider.queue_free()


func fire() -> void:
	can_fire = false
	self.current_ammo -= 1
	check_collision()
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true


func reload() -> void:
	# check if you can reload
	if self.total_ammo > 0:
		# reload the weapon
		reloading = true
		emit_signal("reloading", true, reload_rate)
		yield(get_tree().create_timer(reload_rate), "timeout")
		var reloading_ammo_size = 0
		if self.total_ammo > clip_size:
			self.total_ammo -= clip_size
			reloading_ammo_size = clip_size
		else:
			reloading_ammo_size = self.total_ammo
			self.total_ammo = 0
		self.current_ammo = reloading_ammo_size
		reloading = false
		emit_signal("reloading", false, 0)
	else:
		emit_signal("out_of_ammo")
