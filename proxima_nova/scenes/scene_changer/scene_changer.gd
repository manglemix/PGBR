extends CanvasLayer

signal scene_changed

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var black := $Control/Black as ColorRect

func scene_change(path, delay=0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("Fade")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene(path) == OK)
	animation_player.play_backwards("Fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")
