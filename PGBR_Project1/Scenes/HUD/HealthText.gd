extends VBoxContainer


func _on_HUD_health_updated(health):
	$HealthText.set_text(str(health))
