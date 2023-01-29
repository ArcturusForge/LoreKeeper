extends VBoxContainer

onready var nameInput = $NameContainer/EntityName
onready var graph = $GraphEdit

# Prefabs
onready var freeNode = preload("res://Prefabs/FreeformNode.tscn")

func _ready():
	Globals.connect(Globals.createEntityElementSignal, self, "generate_element")
	Globals.connect(Globals.closeNodeSignal, self, "deleted_node")
	Globals.connect(Globals.resizeNodeSignal, self, "resized_node")
	Globals.connect(Globals.repositionNodeSignal, self, "repositioned_node")
	
	var entityData = Session.get_current_entity()
	if not entityData[0].name == "Rename":
		nameInput.text = entityData[0].name
	# Draw existing nodes
	for i in range(1, entityData.size()):
		draw_element(entityData[i])
	pass

func generate_element(elementIndex: int):
	#TODO:
	var windowName = Globals.style[Globals.windowIndex].window
	var windowConfig = Globals.windowConfigs[windowName]
	var option = windowConfig.fields[elementIndex]
	var newElement = {
		"header" : option.header,
		"fieldIndex" : elementIndex,
		"node" : {"positionX" : 20 * graph.get_child_count(), "positionY" : 20 * graph.get_child_count(), "sizeX" : 330, "sizeY" : 210},
		"data" : []
	}
	Session.get_current_entity().append(newElement)
	draw_element(newElement)
	pass

func draw_element(data):
	#TODO: read data and consturct/draw the specified element.
	var node: GraphNode = freeNode.instance()
	graph.add_child(node)
	node.title = data.header
	node.offset = Vector2(data.node.positionX, data.node.positionY)
	node.rect_min_size = Vector2(data.node.sizeX, data.node.sizeY)
	node.rect_size = Vector2(data.node.sizeX, data.node.sizeY)
	pass

func _on_EntityName_text_entered(new_text):
	var entityData = Session.get_current_entity()
	entityData[0].name = new_text
	Globals.emit_signal(Globals.repaintEntitiesSignal)
	pass

func _on_DeleteEntryBtn_pressed():
	# TODO: Make are you sure popup
	Session.data[Globals.windowIndex].remove(Globals.entityIndex)
	Globals.emit_signal(Globals.redrawAllSignal)
	pass

#TODO: node delete logic
func deleted_node(index: int):
	if index == 0: # data[0] is entity name
		index += 1
	var entityData = Session.get_current_entity()
	entityData.remove(index)
	pass

#TODO: node resize logic
func resized_node(index: int, size: Vector2):
	if index == 0: # data[0] is entity name
		index += 1
	var entityData = Session.get_current_entity()
	entityData[index].node.sizeX = size.x
	entityData[index].node.sizeY = size.y
	pass

#TODO: node movement logic
func repositioned_node(index: int, pos: Vector2):
	if index == 0: # data[0] is entity name
		print ("adding")
		index += 1
		
	var entityData = Session.get_current_entity()
	if index >= entityData.size():
		print ("breaking")
		return
	entityData[index].node.positionX = pos.x
	entityData[index].node.positionY = pos.y
	pass

func _on_EntityFreeformContainer_tree_exited():
	Globals.disconnect(Globals.createEntityElementSignal, self, "generate_element")
	Globals.disconnect(Globals.closeNodeSignal, self, "deleted_node")
	Globals.disconnect(Globals.resizeNodeSignal, self, "resized_node")
	Globals.disconnect(Globals.repositionNodeSignal, self, "repositioned_node")
	pass
