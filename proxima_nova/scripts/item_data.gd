extends Node

var item_data
var loot_data

func _ready():
	item_data = load_json("res://data/item_data_sheet1.json")
	loot_data = load_json("res://data/loot_data_sheet1.json")

func load_json(file_path: String):
	var data_file = File.new()
	data_file.open(file_path, File.READ)
	var data_json = JSON.parse(data_file.get_as_text())
	data_file.close()
	return data_file.result
