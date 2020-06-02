extends Control

class_name StaminaBar

onready var stamina_bar := $StaminaBar as TextureProgress
onready var update_tween := $UpdateTween as Tween
onready var player := get_tree().get_root().get_node("World/Player") as Player

func _process(_delta):
	if player:
		stamina_bar.max_value = player.max_stamina
		stamina_bar.value = player.curr_stamina

#func _on_sprint_updated(time_left: float):
#	print("Stamina: ", map(time_left, 0, 3, 0, 100))
#	update_tween.interpolate_property(stamina_bar, "value", stamina_bar.value, map(time_left, 0, 3, 0, 100), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	update_tween.start()
