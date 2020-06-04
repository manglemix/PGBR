extends Reference


var thread: Thread
var mutex := Mutex.new()
var sem := Semaphore.new()

var queue = []
var pending = {}


func queue_resource(path, p_in_front:=false):
	mutex.lock()
	if path in pending:
		mutex.unlock()
		return
		
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		mutex.unlock()
		return
		
	else:
		var res = ResourceLoader.load_interactive(path)
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		sem.post()
		mutex.unlock()
		return


func cancel_resource(path):
	mutex.lock()
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	mutex.unlock()


func get_progress(path) -> float:
	mutex.lock()
	var ret = -1
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	mutex.unlock()
	return ret


func is_ready(path) -> bool:
	var ret
	mutex.lock()
	if path in pending:
		ret = !(pending[path] is ResourceInteractiveLoader)
	else:
		ret = false
	mutex.unlock()
	return ret


func _wait_for_resource(res, path):
	mutex.unlock()
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		mutex.lock()
		if queue.size() == 0 || queue[0] != res:
			return pending[path]
		mutex.unlock()


func get_resource(path):
	mutex.lock()
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)

			res = _wait_for_resource(res, path)
			pending.erase(path)
			mutex.unlock()
			return res
		else:
			var res = pending[path]
			pending.erase(path)
			mutex.unlock()
			return res
	else:
		mutex.unlock()
		return ResourceLoader.load(path)


func thread_process():
	sem.wait()
	mutex.lock()

	while queue.size() > 0:
		var res = queue[0]
		mutex.unlock()
		var ret = res.poll()
		mutex.lock()

		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				pending[res.get_meta("path")] = res.get_resource()
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			queue.erase(res)
	mutex.unlock()


func thread_func(_u):
	while true:
		thread_process()


func start():
	thread = Thread.new()
	thread.start(self, "thread_func", 0)
