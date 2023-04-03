extends VBoxContainer

onready var nameInput = $NameContainer/EntityName
onready var graph = $GraphEdit
var scrollOffsetCache

# Prefabs
onready var freeNode = preload("res://Prefabs/FreeformNode.tscn")

func _ready():
	graph.get_zoom_hbox().visible = false
	
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
	
	yield(get_tree().create_timer(0.01), "timeout")
	graph.connect("scroll_offset_changed", self, "handle_offset")
	graph.scroll_offset = Session.get_view_cache(Globals.windowIndex + Globals.entityIndex)
	pass

func handle_offset(_offset):
	scrollOffsetCache = graph.scroll_offset
	Session.write_view_cache(Globals.windowIndex + Globals.entityIndex, graph.scroll_offset)
	pass

func generate_element(elementIndex: int):
	var windowName = Globals.style[Globals.windowIndex].window
	var windowConfig = Globals.windowConfigs[windowName]
	var option = windowConfig.fields[elementIndex]
	var newElement = {
		"header" : option.header,
		"fieldIndex" : elementIndex,
		"node" : {"positionX" : graph.scroll_offset.x + 20, "positionY" : graph.scroll_offset.y + 20, "sizeX" : 330, "sizeY" : 210},
		"data" : []
	}
	Session.get_current_entity().append(newElement)
	draw_element(newElement)
	Globals.repaint_app_name(true)
	pass

func draw_element(data):
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
	Globals.repaint_app_name(true)
	pass

# Called when you delete an entity under a category.
func _on_DeleteEntryBtn_pressed():
	#TODO: Make an "are you sure" popup
	Session.data[Globals.windowIndex].remove(Globals.entityIndex)
	Globals.emit_signal(Globals.redrawAllSignal)
	Globals.repaint_app_name(true)
	pass

# Called when you delete a node inside an entity.
func deleted_node(index: int):
	if index == 0: # data[0] is entity name
		index += 1
	var entityData = Session.get_current_entity()
	entityData.remove(index)
	Globals.repaint_app_name(true)
	pass

func resized_node(index: int, size: Vector2):
	if index == 0: # data[0] is entity name
		index += 1
	var entityData = Session.get_current_entity()
	entityData[index].node.sizeX = size.x
	entityData[index].node.sizeY = size.y
	Globals.repaint_app_name(true)
	pass

func repositioned_node(index: int, pos: Vector2):
	if index == 0: # data[0] is entity name
		index += 1
		
	var entityData = Session.get_current_entity()
	if index >= entityData.size():
		return
	entityData[index].node.positionX = pos.x
	entityData[index].node.positionY = pos.y
	Globals.repaint_app_name(true)
	pass

func _on_EntityFreeformContainer_tree_exited():
	Globals.disconnect(Globals.createEntityElementSignal, self, "generate_element")
	Globals.disconnect(Globals.closeNodeSignal, self, "deleted_node")
	Globals.disconnect(Globals.resizeNodeSignal, self, "resized_node")
	Globals.disconnect(Globals.repositionNodeSignal, self, "repositioned_node")
	pass
