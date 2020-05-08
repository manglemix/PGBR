extends Control


var enabled := false setget set_enabled

var _textboxes := []
var _queued_points := {}


func set_enabled(value: bool):
	for node in _textboxes:
		if value:
			node.show()
		else:
			node.hide()
	enabled = value


func append_textboxes(textbox: RichTextLabel):
	_textboxes.append(textbox)
	textbox.set_global_position(Vector2(0, 20 * (len(_textboxes) + 1)))


func create_PropertyObserver(observed_object, property: String):
	var obj = PropertyWatcher.new()
	obj.observed_object = observed_object
	obj.set_property(property)
	add_child(obj)
	append_textboxes(obj)


func draw_points(points, colour:=Color.white, width := 1.0):
	if not enabled:
		return
	
	var screen_space_points := PoolVector2Array()
	var camera = get_viewport().get_camera()
	
	for point in points:
		if camera.is_position_behind(point):
			return
		screen_space_points.append(camera.unproject_position(point))
	_queued_points[screen_space_points] = [colour, width]


func _draw():
	if enabled:
		var metadata: Array
		for lines in _queued_points:
			metadata = _queued_points[lines]
			draw_polyline(lines, metadata[0], metadata[1], true)
	
	_queued_points.clear()


func _process(_delta):
	if enabled:
		update()
