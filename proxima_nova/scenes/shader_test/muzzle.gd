extends Spatial

class_name MuzzleFlash

onready var flash := $FlashParticles as Particles
onready var spark := $SparkParticles as Particles
onready var light := $OmniLight as OmniLight

func muzzle_flash() -> void:
	flash.emitting = true
	spark.emitting = true
	light.visible = true
	yield(get_tree().create_timer(0.2), "timeout")
	light.visible = false
