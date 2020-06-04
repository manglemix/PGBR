extends Spatial

export(String, FILE, "*.tscn") var first_scene: String

onready var resource_queue := preload("res://scripts/resource_queue.gd").new()

enum LoadingStates {
	FADE_TO_BLACK_1,
	FADE_TO_LOADING,
	LOADING,
	FADE_TO_BLACK_2,
	FADE_TO_WORLD,
	PLAYING,
}

var loading_state = LoadingStates.PLAYING
var current_world: Node # already loaded world
var loading_world = null # the world that is loading in progress

func _ready() -> void:
	resource_queue.start()
	
	# load our first scene
	load_world(first_scene)


func _process(delta) -> void:
	if loading_state == LoadingStates.LOADING:
		# update the progress bar here
		var percent := resource_queue.get_progress(loading_world)
		print("Percent: ", percent)
		$LoadingScreen/Loading/LoadingBar.value = percent * 100
		
		# check if our resource is available
		print("LoadingWorld: ", loading_world)
		var new_world = resource_queue.get_resource(loading_world)
		if new_world:
			print("New World: ", new_world)
			# if we're finished create a new instance
			current_world = new_world.instance()
			print("CurrentWorld: ", current_world)
			
			# fade to black
			loading_state = LoadingStates.FADE_TO_BLACK_2
			$Fader.is_faded = true
			set_process(false)


func load_world(scene_to_load):
	# Remember which scene we are loading
	loading_world = scene_to_load
	
	# start loading
	resource_queue.queue_resource(loading_world)
	
	# fade to black, if we're already faded to black (startup) we get our signal immediately
	loading_state = LoadingStates.FADE_TO_BLACK_1
	$Fader.is_faded = true


func _on_Fader_finished_fading():
	match loading_state:
		LoadingStates.FADE_TO_BLACK_1:
			# hide out world scene
			$WorldScene.visible = false
			
			# remove our current world
			if current_world:
				$WorldScene.remove_child(current_world)
				current_world.queue_free()
				current_world = null
			
			# show the loading screen
			$LoadingScreen/Loading.visible = true
			
			# fade to transparent
			loading_state = LoadingStates.FADE_TO_LOADING
			$Fader.is_faded = false
			
		LoadingStates.FADE_TO_LOADING:
			# simply change the state to loading
			loading_state = LoadingStates.LOADING
			set_process(true)
		LoadingStates.FADE_TO_BLACK_2:
			# hide our loading screen
			$LoadingScreen/Loading.visible = false
			
			# add our new world scene
			$WorldScene.add_child(current_world)
			$WorldScene.visible = true
			
			# fade to transparent
			loading_state = LoadingStates.FADE_TO_WORLD
			$Fader.is_faded = false
		LoadingStates.FADE_TO_WORLD:
			# simply set the state to playing
			loading_state = LoadingStates.PLAYING
		_:
			# Nothing to do in all other cases
			pass
