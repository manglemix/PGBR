extends Control


var enabled := false setget set_enabled

var _textboxes := []
var _queued_points := {}
var _dots := {}


func set_enabled(value: bool):
	for node in _textboxes:
		if value:
			node.show()
		else:
			node.hide()
	
	enabled = value
	set_process(value)
	update()


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
	if enabled:
		var screen_points := PoolVector2Array()
		var camera = get_viewport().get_camera()
		
		for point in points:
			if camera.is_position_behind(point):
				return
			screen_points.append(camera.unproject_position(point))
		_queued_points[screen_points] = [colour, width]


func draw_points_from_origin(points, colour:=Color.white, width := 1.0):
	if enabled:
		var screen_points := PoolVector2Array()
		var camera = get_viewport().get_camera()
		
		var point: Vector3
		for i in range(len(points)):
			point = points[i]
			if i > 0:
				point += points[0]
			
			if camera.is_position_behind(point):
				return
			screen_points.append(camera.unproject_position(point))
		_queued_points[screen_points] = [colour, width]


func draw_dot(position, colour:=Color.white, radius:=5):
	if enabled:
		_dots[position] = [radius, colour]


func draw_transform(transform: Transform, width := 1.0):
	draw_points_from_origin([transform.origin, transform.basis.x], Color.red, width)
	draw_points_from_origin([transform.origin, transform.basis.y], Color.green, width)
	draw_points_from_origin([transform.origin, transform.basis.z], Color.blue, width)


func _draw():
	if enabled:
		var metadata: Array
		for lines in _queued_points:
			metadata = _queued_points[lines]
			draw_polyline(lines, metadata[0], metadata[1], true)
		
		var camera = get_viewport().get_camera()
		for dot in _dots:
			if camera.is_position_behind(dot):
				continue
			
			metadata = _dots[dot]
			draw_circle(camera.unproject_position(dot), metadata[0], metadata[1])
	
	_queued_points.clear()


func _process(_delta):
	update()
