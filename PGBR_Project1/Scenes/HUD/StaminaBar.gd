extends Control

class_name StaminaBar

onready var stamina_bar := $StaminaBar as TextureProgress
onready var update_tween := $UpdateTween as Tween
onready var player := get_tree().get_root().get_node("Draft/Person") as BasePerson

func map(x: float, in_min: float, in_max: float, out_min: float, out_max: float):
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


func _process(delta):
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = player.curr_stamina
