extends GraphNode

var nodeIndex

func _ready():
	nodeIndex = self.get_index() - 1
	Globals.connect(Globals.refreshNodeSignal, self, "refresh")
	Globals.connect(Globals.removeElementSignal, self, "redraw_on_delete")
	Globals.connect(Globals.addElementSignal, self, "add_listed_element")
	Globals.connect(Globals.closeNodeSignal, self, "handle_sibling_delete")
	generate_fields()
	pass

func refresh():
	self.title = Session.get_current_entity()[nodeIndex].header
	pass

# Called when a sibling node is deleted from the entity.
func handle_sibling_delete(siblingNodeIndex):
	if siblingNodeIndex < self.nodeIndex:
		nodeIndex -= 1
		generate_fields()
	pass

func redraw_on_delete(nodeIndex):
	if self.nodeIndex == nodeIndex:
		generate_fields()
	pass

func add_listed_element(listNodeIndex, listParent, newElementIndex):
	# This check stops data duplication across listed nodes.
	if not listNodeIndex == self.nodeIndex:
		return
	
	var windowData = Globals.get_current_window()
	var fieldData = windowData.fields[Session.get_current_entity()[nodeIndex].fieldIndex]
	var elementData = Globals.elementConfigs[fieldData.type]
	var constructor = elementData.construct
	var sepInterval = elementData.seperatorInterval
	var seperator = elementData.seperator
	generate_element(listParent, listNodeIndex, newElementIndex, constructor, seperator, sepInterval, true)
	
	var addBtn = Globals.elementListBtnPrefab.instance()
	addBtn.nodeIndex = nodeIndex
	addBtn.listParent = listParent
	var entityData = Session.get_current_entity()
	addBtn.listElementIndex = entityData[nodeIndex].data.size()
	addBtn.text = fieldData.listPrompt
	listParent.add_child(addBtn)
	pass

func generate_fields():
	if self.get_child_count() > 0:
		for i in range(self.get_child_count() - 1, -1, -1):
			self.get_child(i).queue_free()
	
	var windowData = Globals.get_current_window()
	var fieldData = windowData.fields[Session.get_current_entity()[nodeIndex].fieldIndex]
	var elementData = Globals.elementConfigs[fieldData.type]
	var constructor = elementData.construct
	var sepInterval = elementData.seperatorInterval
	var seperator = elementData.seperator
	
	var parent = self
	var elementIndex = 0
	
	if fieldData.asList == true:
		var listNode = get_prefab(fieldData.listType)
		parent.add_child(listNode)
		parent = listNode.elementContainer
		var entityData = Session.get_current_entity()
		for i in range(0, entityData[nodeIndex].data.size()):
			elementIndex = i
			generate_element(parent, nodeIndex, elementIndex, constructor, seperator, sepInterval, true)
		# Adds an "Add new element to list" button
		var addBtn = Globals.elementListBtnPrefab.instance()
		addBtn.nodeIndex = nodeIndex
		addBtn.listParent = parent
		addBtn.listElementIndex = entityData[nodeIndex].data.size()
		addBtn.text = fieldData.listPrompt
		parent.add_child(addBtn)
		pass
	else:
		generate_element(parent, nodeIndex, elementIndex, constructor, seperator, sepInterval)
	pass

func generate_element(parent, nodeIndexParam:int, elementIndex:int, constructor, seperator, sepInterval, inList = false):
	var segmentIndex = 0
	
	if constructor.size() > 1:
		var segContainer = Globals.elementSegmentPrefab.instance()
		parent.add_child(segContainer)
		parent = segContainer
		var sepCount = 0
		for i in range(0, constructor.size()):
			if sepCount >= sepInterval && seperator != "":
				# Generate seperator
				var sepInst = Globals.elementSeperatorPrefab.instance()
				sepInst.text = seperator
				parent.add_child(sepInst)
				sepCount = 0
				pass
			sepCount += 1
			generate_segment(parent, nodeIndexParam, elementIndex, segmentIndex, constructor, inList)
			segmentIndex += 1
			pass
	else:
		generate_segment(parent, nodeIndexParam, elementIndex, segmentIndex, constructor, inList)
	pass

func generate_segment(parent, nodeIndexParam:int, elementIndex:int, segmentIndex:int, constructor, inList):
	# Ensure session can hold data for node
	var entityData = Session.get_current_entity()
	if entityData[nodeIndexParam].data.size() <= elementIndex:
		var segmentData = []
		entityData[nodeIndexParam].data.append(segmentData)
	
	# Generate the only segment for this node
	var inst = get_prefab(constructor[0])
	inst.nodeIndex = nodeIndexParam
	inst.elementIndex = elementIndex
	inst.segmentIndex = segmentIndex
	inst.inList = inList
	parent.add_child(inst)
	pass

func get_prefab(type: String):
	var windowData = Globals.get_current_window()
	var fieldData = windowData.fields[Session.get_current_entity()[nodeIndex].fieldIndex]
	var elementData = Globals.elementConfigs[fieldData.type]
	if Functions.is_app():
		return load(Functions.os_path_convert("res://AppData/Custom/FreeformElements/Prefabs/" + type)).instance()
	else:
		return load("res://AppData/Custom/FreeformElements/Prefabs/" + type).instance()

func _on_FreeformNode_close_request():
	Globals.disconnect(Globals.closeNodeSignal, self, "handle_sibling_delete")
	Globals.emit_signal(Globals.closeNodeSignal, nodeIndex)
	self.queue_free()
	pass

func _on_FreeformNode_resize_request(new_minsize):
	self.rect_min_size = Vector2(0, 0)
	self.rect_size = new_minsize
	Globals.emit_signal(Globals.resizeNodeSignal, nodeIndex, self.rect_size)
	pass

func _on_FreeformNode_dragged(_from, _to):
	Globals.emit_signal(Globals.repositionNodeSignal, nodeIndex, self.offset)
	pass

func _on_FreeformNode_gui_input(event):
	if (event.is_pressed() and event.button_index == BUTTON_RIGHT):
		#Globals.emit_signal(Globals.requestContextMenuSignal, nodeIndex, self.get_global_mouse_position())
		Globals.emit_signal(Globals.requestContextMenuSignal, self)
	pass

func handle_popup(contextMenu:PopupMenu):
	contextMenu.connect("id_pressed", self, "handle_popup_selection")
	contextMenu.set_position(self.get_global_mouse_position())
	contextMenu.clear()
	contextMenu.add_separator("Options")
	contextMenu.add_item("Rename", 0)
	contextMenu.popup()
	pass

func handle_popup_selection(id):
	Globals.emit_signal(Globals.disconnectContextMenuSignal, self, "id_pressed", "handle_popup_selection")
	match id:
		0: 
			Globals.emit_signal(Globals.requestNodeRenameSignal, nodeIndex, self.title, self.get_global_mouse_position())
			pass
	pass

func _on_FreeformNode_tree_exited():
	Globals.disconnect(Globals.refreshNodeSignal, self, "refresh")
	pass
