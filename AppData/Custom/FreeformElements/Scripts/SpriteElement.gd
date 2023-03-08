extends Button

onready var texture_rect = $TextureRect
onready var deleteBtn = $DeleteElementButton

var nodeIndex # Assigned by freeform node to enable segmented elements.
var elementIndex # Assigned by ffn to enable listed elements.
var segmentIndex # Assigned by ffn to enable segmented elements.
var inList # Assigned by ffn to determine list display settings.

var hideCounter = 0

# Returns the current entity's session data
func _get_element_data():
	var entityData = Session.get_current_entity()
	return entityData[nodeIndex].data[elementIndex]

# Segments are elements that are used as a component of an overarching element.
# All data is set-up this way for compatibility.
func _get_segment_data():
	var elementData = _get_element_data()
	return elementData[segmentIndex]

# Sets a default entry into the session data so this element is compatible with list displays.
# Append your own data to the end of the default data.
func _set_default_data():
	var elementData = _get_element_data()
	if elementData.size() <= segmentIndex:
		elementData.append([rect_min_size.x, rect_min_size.y])
	pass

# Will return bool depending on whether the session has existing data for this element.
func _default_data_exists():
	var elementData = _get_element_data()
	if elementData.size() > segmentIndex:
		return true
	else:
		return false

# Will return bool depending on whether custom data at a specific index exists.
# All custom data starts at index 2.
func _custom_data_exists(dataIndex:int):
	var data = _get_segment_data()
	if data.size() > dataIndex:
		return true
	else:
		return false

# Removes the element data from a node and then causes a node redraw.
func delete_element():
	var entityData = Session.get_current_entity()
	entityData[nodeIndex].data.remove(elementIndex)
	Globals.emit_signal(Globals.removeElementSignal, nodeIndex)
	pass

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
		deleteBtn.visible = true
		_resize_for_list(200, 200)
	pass

func _process(delta):
	if deleteBtn.visible == true:
		hideCounter += delta
		if hideCounter >= 1.5:
			deleteBtn.visible = false
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
	Functions.set_app_name(true)
	pass

func _on_DeleteElementButton_pressed():
	delete_element()
	pass

func _on_SpriteElement_mouse_entered():
	if inList:
		if segmentIndex == 0:
			deleteBtn.visible = true
			hideCounter = 0
	pass
