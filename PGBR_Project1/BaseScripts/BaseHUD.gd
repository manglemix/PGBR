# this node is responsible for forwarding player resource signals
extends Control


signal health_updated(health)
signal max_health_updated(max_health)
signal stamina_updated(stamina)
signal max_stamina_updated(max_stamina)

var player setget set_player


func _ready():
	get_tree().get_current_scene().connect("player_changed", self, "set_player")


func update_health(health: float):
	emit_signal("health_updated", health)


func update_max_health(max_health: float):
	emit_signal("max_health_updated", max_health)


func update_stamina(stamina: float):
	emit_signal("stamina_updated", stamina)


func update_max_stamina(max_stamina: float):
	emit_signal("max_stamina_updated", max_stamina)


func set_player(node):
	if is_instance_valid(player):
		player.disconnect("health_updated", self, "update_health")
		player.disconnect("max_health_updated", self, "update_max_health")
		
		player.disconnect("stamina_updated", self, "update_stamina")
		player.disconnect("max_stamina_updated", self, "update_max_stamina")
	
	player = node
	
	player.connect("health_updated", self, "update_health")
	player.connect("max_health_updated", self, "update_max_health")
	
	player.connect("stamina_updated", self, "update_stamina")
	player.connect("max_stamina_updated", self, "update_max_stamina")
