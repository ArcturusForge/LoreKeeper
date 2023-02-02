extends GraphNode

var nodeIndex

func _ready():
	nodeIndex = self.get_index() - 1
	Globals.connect(Globals.refreshNodeSignal, self, "refresh")
	Globals.connect(Globals.removeElementSignal, self, "redraw_on_delete")
	generate_fields()
	pass

func refresh():
	self.title = Session.get_current_entity()[nodeIndex].header
	pass

func redraw_on_delete(nodeIndex):
	if self.nodeIndex == nodeIndex:
		generate_fields()
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
		#TODO: Read exisiting listed elements.
		#TODO: Generate a list container
		#TODO: Loop generate_element and increment the elementIndex
		var listNode = get_prefab(fieldData.listType)
		parent.add_child(listNode)
		parent = listNode.elementContainer
		var entityData = Session.get_current_entity()
		for i in range(0, entityData[nodeIndex].data.size()): #PROPER
		#for i in range(0, 3): #TESTING
			elementIndex = i
			generate_element(parent, nodeIndex, elementIndex, constructor, seperator, sepInterval, true)
		#TODO: Add an "Add new element to list" button
		
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
			sepCount += 1
			if sepCount >= sepInterval && seperator != "":
				#TODO: generate seperator
				sepCount = 0
				pass
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
	return load("res://AppData/Custom/FreeformElementPrefabs/" + type).instance()

func _on_FreeformNode_close_request():
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
		Globals.emit_signal(Globals.requestContextMenuSignal, nodeIndex, self.get_global_mouse_position())
	pass

func _on_FreeformNode_tree_exited():
	Globals.disconnect(Globals.refreshNodeSignal, self, "refresh")
	pass
