extends Control

class_name HealthBar


export var danger_zone := 0.3
export var pulse_color_from := Color.red
export var pulse_color_to := Color.darkred
var pulse_color_under := pulse_color_to
export var will_pulse := true


onready var health_bar_under := $HealthBarUnder as TextureProgress
onready var health_bar := $HealthBar as TextureProgress
onready var update_tween := $UpdateTween as Tween
onready var pulse_tween := $PulseTween as Tween
onready var player := get_tree().get_root().find_node("Player", true, false) as Player
onready var og_under_color := health_bar_under.tint_progress
onready var og_color := health_bar.tint_progress


func _ready():
	pulse_color_under.a8 = 130
	if player:
		var connStat = player.connect('update_health', self, '_on_health_updated')
		if connStat != OK:
			print("player -> update_health Connection Error!")


func _on_health_updated(health: float) -> void:
	health_bar.value = health
	update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health_bar.value, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	update_tween.start()
	if health <= 0 or health > health_bar.max_value * danger_zone:
		pulse_tween.set_active(false)
		health_bar.tint_progress = og_color
		health_bar_under.tint_progress = og_under_color
	elif health < health_bar.max_value * danger_zone:
		if will_pulse:
			if not pulse_tween.is_active():
				health_bar_under.tint_progress = pulse_color_under
				pulse_tween.interpolate_property(health_bar, 'tint_progress', pulse_color_from, pulse_color_to, 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
				pulse_tween.start()


func _on_max_health_updated(max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar_under.max_value = max_health
