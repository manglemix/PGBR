# Loads the filename given in a separate thread
class_name ResourceQueue
extends Reference


signal done			# emitted when the Thread has exited

var _done := false									# true if the thread has exited
var _resource_loader: ResourceInteractiveLoader		# loads the Resource using the filename given
var _resource: Resource								# the final Resource, which was to be loaded
var _loader_thread := Thread.new()					# the Thread responsible for polling the ResourceInteractiveLoader
var _last_error := OK								# the last error returned by _resource_loader.poll()
var _exit_thread := false							# if true, the thread will try to exit


func _init(filename: String):
	_resource_loader = ResourceLoader.load_interactive(filename)


func start() -> void:
	# Starts the ResourceInteractiveLoader in a separate thread
	_loader_thread.start(self, "load_resource")


func exit_thread():
	_exit_thread = true


func load_resource(_u) -> void:
	# This is the function run in _loader_thread
	while _last_error == OK:
		if _exit_thread:
			break
		_last_error = _resource_loader.poll()
	
	_done = true
	if _last_error == ERR_FILE_EOF:
		_resource = _resource_loader.get_resource()
	call_deferred("emit_signal", "done")


func get_error() -> int:
	# Returns the last error code if there was any
	return _last_error


func is_done() -> bool:
	# Returns true if the Thread is finished
	return _done


func get_progress() -> float:
	# returns a float between 0 and 1 representing the fraction of the Resource loaded
	# We have to convert this to a float, otherwise it'll be int / int which returns an int
	# We also have to add 1 beacuse we are referring to the current stage, whereas get_stage refers to the last stage completed
	return float(_resource_loader.get_stage() + 1) / _resource_loader.get_stage_count()


func get_resource() -> Resource:
	# Returns the loaded resource, or null if it hasn't loaded
	return _resource
