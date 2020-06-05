extends Node

onready var new_game := $MainMenuUI/MenuBg/MenuItems/NewGame as TextureButton
onready var load_game := $MainMenuUI/MenuBg/MenuItems/Load as TextureButton
onready var options := $MainMenuUI/MenuBg/MenuItems/Options as TextureButton
onready var quit := $MainMenuUI/MenuBg/MenuItems/Quit as TextureButton

export var new_game_path: PackedScene


func _ready():
	new_game.connect("pressed", self, "new_game_click")
	load_game.connect("pressed", self, "load_game_click")
	options.connect("pressed", self, "options_click")
	quit.connect("pressed", self, "quit_click")


func new_game_click():
	var err := get_tree().change_scene("res://scenes/islands/first_level.tscn")
	if err != OK:
		printerr("An error occured while trying to load the first level: ", err)


func load_game_click():
	if Saves.game_config.has_section_key("save_info", "last_save_name"):
		var err := get_tree().change_scene("res://scenes/world/loaded_game.tscn")
		if err != OK:
			printerr("An error occured while trying to load the first level: ", err)
	
	else:
		print_debug("no save game found")


func options_click():
	pass


func quit_click():
	get_tree().quit()
