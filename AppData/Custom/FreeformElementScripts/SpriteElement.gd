extends Button

onready var texture_rect = $TextureRect

var nodeIndex # Assigned by freeform node to enable segmented elements.
var elementIndex # Assigned by ffn to enable listed elements.
var segmentIndex # Assigned by ffn to enable segmented elements.
var inList # Assigned by ffn to determine list display settings.

# returns the current entity's session data
func _get_element_data():
	var entityData = Session.get_current_entity()
	return entityData[nodeIndex].data[elementIndex]

# Write whatever funcs you need to operate the element type properly below.
func _ready():	
	var elementData = _get_element_data()
	# Load any existing data from the current session.
	if elementData.size() > segmentIndex:
		var encodeData = elementData[segmentIndex]
		if encodeData[2] != "" && encodeData[3] != "": # Null check to mitigate a bug
			texture_rect.texture = Functions.load_image_from_encode(encodeData[2], encodeData[3])
		# Resize element for the list
		if inList:
			_resize_for_list(encodeData[0], encodeData[1])
	# Check if the new element is part of a list and resize it.
	#TODO: make menu option to resize elements in a list.
	elif inList:
		_resize_for_list(100, 100)
	pass

func _resize_for_list(x:int, y:int):
	rect_min_size = Vector2(x, y)
	var elementData = _get_element_data()
	if elementData.size() <= segmentIndex:
		elementData.append([rect_min_size.x, rect_min_size.y, "", ""])
	else:
		elementData[segmentIndex][0] = rect_min_size.x
		elementData[segmentIndex][1] = rect_min_size.y
	pass

func _on_SpriteElement_pressed():
	var filters = [
		"*.png",
		"*.jpg",
		"*.tga",
		"*.bmp",
		"*.webp"
	]
	var access = 2
	var mode = 0
	Globals.emit_signal(Globals.requestFileFinder, filters, access, mode, "Select an image file.", "Select Image")
	Globals.connect(Globals.receiveFileFinder, self, "get_image")
	pass

func get_image(path: String):
	Globals.disconnect(Globals.receiveFileFinder, self, "get_image")
	var imageData = Functions.load_image_and_encode(path)
	texture_rect.texture = imageData[2]
	
	var elementData = _get_element_data()
	if elementData.size() <= segmentIndex:
		elementData.append([rect_min_size.x, rect_min_size.y, imageData[0], imageData[1]])
	else:
		elementData[segmentIndex][2] = imageData[0]
		elementData[segmentIndex][3] = imageData[1]
	pass
