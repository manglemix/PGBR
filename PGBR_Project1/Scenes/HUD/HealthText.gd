extends VBoxContainer


func _on_health_updated(health: float):
	$HealthText.set_text(str(health))


func _on_max_health_updated(health: float):
	pass
