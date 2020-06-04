extends Node


func _ready():
	play_game()
	

func play_game():
	if Saves.read_save_data("") == OK:
		get_tree().change_scene("res://loaded_game.tscn")
	else:
		get_tree().change_scene("res://first_level.tscn")
