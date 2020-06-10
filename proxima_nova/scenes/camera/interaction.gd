extends RayCast

var current_collider: Interactable

onready var interaction_label := get_node("/root/World/HUD/UI/Interact") as Label

func _ready():
	set_interaction_text("")

func _process(delta: float) -> void:
	var collider := get_collider()
	
	if is_colliding() and collider is Interactable:
		if current_collider != collider:
			set_interaction_text(collider.get_interaction_text())
			current_collider = collider as Interactable
		
		if Input.is_action_just_pressed("interact"):
			(collider as Interactable).interact()
			set_interaction_text(collider.get_interaction_text())
	
	elif current_collider:
		current_collider = null
		set_interaction_text("")

func set_interaction_text(text: String) -> void:
	if interaction_label:
		if !text:
			interaction_label.set_text("")
			interaction_label.set_visible(false)
		else:
			var interact_key := OS.get_scancode_string(InputMap.get_action_list("interact")[0].scancode as int) as String
			interaction_label.set_text("Press %s to %s" % [interact_key, str(text)])
			interaction_label.set_visible(true)
