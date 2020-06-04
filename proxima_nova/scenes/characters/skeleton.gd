extends Skeleton

var ragdoll := false

func _process(delta):
	if Input.is_action_just_pressed("ragdoll"):
		ragdoll = not ragdoll
		toggle_ragdoll()

func toggle_ragdoll():
	if ragdoll:
		physical_bones_start_simulation()
	else:
		physical_bones_stop_simulation()
