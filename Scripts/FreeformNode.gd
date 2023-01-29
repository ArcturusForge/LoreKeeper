extends GraphNode

var index

func _ready():
	index = self.get_index() - 1
	Globals.connect(Globals.refreshNodeSignal, self, "refresh")
	generate_fields()

func refresh():
	self.title = Session.get_current_entity()[index].header
	pass

func generate_fields():
	#TODO:
	# - Read window data for if is list
	# - Read element data to generate fields
	var windowData = Globals.get_current_window()
	var fieldData = windowData.fields[Session.get_current_entity()[index].fieldIndex]
	var elementData = Globals.elementConfigs[fieldData.type]
	var constructor = elementData.construct
	var sepInterval = elementData.seperatorInterval
	var seperator = elementData.seperator
	
	var parent
	if constructor.size() > 1: 
		#TODO: 
		# Figure out how to do this because right now it won't work.
		# Session data won't track correctly in list formats and 
		# sibling nodes won't identify the correct data.
		
		#TODO: add hContainer
		#parent = hContainer
		pass
	else:
		parent = self
		var inst = get_prefab(constructor[0])
		parent.add_child(inst)
	
	#TODO: Read session data
	pass

func get_prefab(type: String):
	match type:
		"sprite":
			return Globals.spritePrefab.instance()

func _on_FreeformNode_close_request():
	Globals.emit_signal(Globals.closeNodeSignal, index)
	self.queue_free()
	pass

func _on_FreeformNode_resize_request(new_minsize):
	self.rect_min_size = Vector2(0, 0)
	self.rect_size = new_minsize
	Globals.emit_signal(Globals.resizeNodeSignal, index, self.rect_size)
	pass

func _on_FreeformNode_dragged(_from, _to):
	Globals.emit_signal(Globals.repositionNodeSignal, index, self.offset)
	pass

func _on_FreeformNode_gui_input(event):
	if (event.is_pressed() and event.button_index == BUTTON_RIGHT):
		Globals.emit_signal(Globals.requestContextMenuSignal, index, self.get_global_mouse_position())
	pass

func _on_FreeformNode_tree_exited():
	Globals.disconnect(Globals.refreshNodeSignal, self, "refresh")
	pass
