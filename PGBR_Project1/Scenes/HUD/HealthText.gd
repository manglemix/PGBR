extends VBoxContainer

onready var health_text := $HealthText as Label
onready var player := get_tree().get_root().get_node("Draft/Person") as BasePerson


func _ready():
	player.connect('update_health', self, '_on_health_updated')


func _on_health_updated(health: float) -> void:
	health_text.set_text(str(health))
