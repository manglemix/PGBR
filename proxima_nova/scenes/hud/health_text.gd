extends VBoxContainer

onready var health_text := $HealthText as Label
onready var player := get_tree().get_root().get_node("World/Player") as Player


func _ready():
	if player:
		var conStat := player.connect('update_health', self, '_on_health_updated')
		if conStat != OK:
			print("player connection error")


func _on_health_updated(health: float) -> void:
	health_text.set_text(str(health))
