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
	assert(get_tree().change_scene_to(new_game_path) == OK)


func load_game_click():
	pass


func options_click():
	pass


func quit_click():
	get_tree().quit()
