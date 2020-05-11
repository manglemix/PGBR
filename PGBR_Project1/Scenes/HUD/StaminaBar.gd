class_name StaminaBar
extends Control


#func map(x: float, in_min: float, in_max: float, out_min: float, out_max: float):
#	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


func _on_max_stamina_updated(max_stamina):
	$StaminaBar.max_value = max_stamina


func _on_stamina_updated(stamina):
	$StaminaBar.value = stamina
