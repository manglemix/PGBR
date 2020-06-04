extends Interactable

export var light: NodePath
export var on_by_default := true
export var energy_when_on := 2
export var energy_when_off := 0

onready var light_node := get_node(light) 
onready var on := on_by_default

func _ready() -> void:
	set_light_energy()

func get_interaction_text() -> String:
	return "Switch light Off" if on else "Switch light On"

func interact() -> void:
	on = !on
	set_light_energy()

func set_light_energy() -> void:
	light_node.set_param(Light.PARAM_ENERGY, energy_when_on if on else energy_when_off)

