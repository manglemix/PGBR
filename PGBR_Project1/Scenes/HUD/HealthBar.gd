class_name HealthBar
extends Control


export var danger_zone := 0.3
export var pulse_color_from := Color.red
export var pulse_color_to := Color.darkred
var pulse_color_under := pulse_color_to
export var will_pulse := true

onready var og_under_color := $MaxHealthBar.tint_progress as Color
onready var og_color := $HealthBar.tint_progress as Color


func _ready():
	pulse_color_under.a8 = 130


func _on_HUD_health_updated(health):
	$HealthBar.value = health
	$UpdateTween.interpolate_property($MaxHealthBar, "value", $MaxHealthBar.value, $HealthBar.value, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
	$UpdateTween.start()
	
	if health <= 0 or health > $HealthBar.max_value * danger_zone:
		$PulseTween.set_active(false)
		$HealthBar.tint_progress = og_color
		$MaxHealthBar.tint_progress = og_under_color
		
	elif health < $HealthBar.max_value * danger_zone:
		if will_pulse:
			if not $PulseTween.is_active():
				$MaxHealthBar.tint_progress = pulse_color_under
				$PulseTween.interpolate_property($HealthBar, 'tint_progress', pulse_color_from, pulse_color_to, 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
				$PulseTween.start()


func _on_HUD_max_health_updated(max_health):
	$HealthBar.max_value = max_health
	$MaxHealthBar.max_value = max_health
