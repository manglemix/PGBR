class_name PropertyWatcher
extends RichTextLabel


export(String) var property
var observed_object
var properties: PoolStringArray


func _ready():
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	set_property(property)
	
	if get_parent() != Debug:
		observed_object = get_parent()
		get_parent().remove_child(self)
		Debug.add_child(self)
		Debug.append_textboxes(self)


func set_property(property_name: String):
	property = property_name
	properties = property.rsplit('.')


func _process(delta):
	if not is_instance_valid(observed_object):
		queue_free()
		return
	
	var obj = observed_object
	for string in properties:
		if not is_instance_valid(obj):
			break
		obj = obj.get(string)
	bbcode_text = str(observed_object) + '.' + property + ': ' + str(obj)
