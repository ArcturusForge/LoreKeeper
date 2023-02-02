extends TextEdit

var nodeIndex # Assigned by freeform node to enable segmented elements.
var elementIndex # Assigned by ffn to enable listed elements.
var segmentIndex # Assigned by ffn to enable segmented elements.
var inList # Assigned by ffn to determine list display settings.

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
	if _default_data_exists() == true && _custom_data_exists(2):
		var data = _get_segment_data()
		self.text = data[2]
	else:
		_set_default_data()
	pass

func _on_LargeTextEdit_text_changed():
	var data = _get_segment_data()
	if _custom_data_exists(2):
		data[2] = self.text
	else:
		data.append(self.text)
	pass
