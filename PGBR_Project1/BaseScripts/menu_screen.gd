extends Node


var res_directory := Directory.new()


func _ready():
	res_directory.open("res://")
	play_game()
	

func play_game():
	if Saves.read_save_data("") == OK:
		get_tree().change_scene("res://LoadedGame.tscn")
	else:
		get_tree().change_scene("res://FirstLevel.tscn")
