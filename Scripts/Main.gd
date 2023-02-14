extends Control

# Vars
onready var app_bg = $AppBg

onready var startOverlay = $StartOverlay
onready var seshDialogue: FileDialog = $SessionFileDialog # Ahh the wonders of international spelling...
onready var styleDialogue: PopupMenu = $StyleFileDialogue
onready var saveAsDialogue: FileDialog = $SaveSessionDialogue
onready var fileFinderDialogue: FileDialog = $FileFinderDialog

onready var nodeContextMenu = $NodeContextMenu
onready var nodeRenameDialogue = $NodeRenameDialogue
onready var nodeRenameInput = $NodeRenameDialogue/LineEdit

onready var categoryContainer = $Control/CategoryContainer
onready var windowHeader = $HSplitContainer/ColorRect/WindowHeader
onready var entitiesContainer = $HSplitContainer/ColorRect/EntitiesControl
onready var entityContainer = $HSplitContainer/ColorRect2/EntityControl
onready var AddAttributableBtn = $Control/AddAttributableButton
onready var OptionsBtn = $Control/FileOptionsButton

# Dynamics
var categoryBar
var entitiesCollectionContainer
var entityCollectionContainer

# Prefabs
onready var menuBtn = preload("res://Prefabs/MenuBtn.tscn")
onready var categoryBarPrefab = preload("res://Prefabs/CategoryBar.tscn")

onready var entitiesContainerPrefab = preload("res://Prefabs/EntitiesContainer.tscn")
onready var newEntityBtn = preload("res://Prefabs/AddEntityBtn.tscn")
onready var viewEntityBtn = preload("res://Prefabs/ViewEntityBtn.tscn")

onready var selectEntityWindowPrefab = preload("res://Prefabs/SelectEntityWindow.tscn")
onready var entityListWindowPrefab = preload("res://Prefabs/EntityListContainer.tscn")
onready var entityFreeformWindowPrefab = preload("res://Prefabs/EntityFreeformContainer.tscn")

func _ready():
	startOverlay.visible = true
	categoryBar = $Control/CategoryContainer/CategoryBar
	entitiesCollectionContainer = $HSplitContainer/ColorRect/EntitiesControl/collectionContainer
	entityCollectionContainer = $HSplitContainer/ColorRect2/EntityControl/collectionContainer
	
	# Save
	set_options_shortcut(0, KEY_S, true)
	# Save As
	set_options_shortcut(1, KEY_S, true, true)
	# Load
	set_options_shortcut(3, KEY_L, true)
	# New
	set_options_shortcut(4, KEY_N, true)
	
	# Global event signal subscription
	Globals.connect(Globals.menuSelectedSignal, self, "select_menu")
	Globals.connect(Globals.createEntrySignal, self, "create_entry")
	Globals.connect(Globals.viewEntrySignal, self, "view_entry")
	Globals.connect(Globals.redrawAllSignal, self, "handle_redraw_all")
	Globals.connect(Globals.requestContextMenuSignal, self, "context_menu_request")
	Globals.connect(Globals.disconnectContextMenuSignal, self, "disconnect_from_context_menu")
	Globals.connect(Globals.requestNodeRenameSignal, self, "node_rename_dialogue_request")
	Globals.connect(Globals.requestFileFinder, self, "assign_file_finder")
	
	# Local event signal subscription
	AddAttributableBtn.get_popup().connect("id_pressed", self, "on_attributable_selected")
	OptionsBtn.get_popup().connect("id_pressed", self, "on_option_selected")
	
	# Check for directory and defaults integrity
	Globals.check_folder_integrity()
	Globals.check_defaults_integrity()
	
	var file = File.new()
	if Functions.is_app():
		file.open(Functions.os_path_convert(Globals.cachePath + "config.lki"), File.READ)
	else:
		file.open(Globals.cachePath + "config.lki", File.READ)
	var cache = parse_json(file.get_as_text())
	file.close()
	app_bg.texture = Functions.load_image_from_encode(cache.extension, cache.bg)
	
	# Locate and iterate over every element type
	var elements = Functions.get_all_files(Globals.elementsPath, Globals.elementExtension)
	for element in elements:
		load_element_config(element)
	
	# Locate and iterate over every window type
	var windows = Functions.get_all_files(Globals.windowsPath, Globals.windowExtension)
	for window in windows:
		load_window_config(window)
	
	# Locate and iterate over every style type
	var styles = Functions.get_all_files(Globals.stylesPath, Globals.styleExtension)
	for style in styles:
		load_style_config(style)
	pass

func set_options_shortcut(optionIndex, scancode, useControl:bool = true, useShift:bool = false):
	var shortcut = ShortCut.new()
	var inputKey = InputEventKey.new()
	inputKey.set_scancode(scancode)
	inputKey.control = useControl
	inputKey.shift = useShift
	shortcut.set_shortcut(inputKey)
	OptionsBtn.get_popup().set_item_shortcut(optionIndex, shortcut, true)
	pass

func load_existing_session(path: String):
	Session.load_data(path)
	select_style(Session.styleUsed)
	display_style()
	Functions.set_app_name()
	pass

func start_new_session():
	Session.reset_data()
	
	Session.styleUsed = Globals.currentStyle
	for index in Globals.style.size():
		var dat = []
		Session.data.append(dat)
	
	display_style()
	Functions.set_app_name()
	pass

func parse_config(data):	
	if not Globals.styleConfigs.has(data.style):
		select_style("Default." + Globals.styleExtension)
	else:
		# Load the set style
		select_style(data.style)
	pass

func load_element_config(path: String):
	var file = File.new()
	file.open(path, File.READ)
	Globals.elementConfigs[path.get_file()] = parse_json(file.get_as_text())
	file.close()
	pass

func load_window_config(path: String):
	var file = File.new()
	file.open(path, File.READ)
	Globals.windowConfigs[path.get_file()] = parse_json(file.get_as_text())
	file.close()
	pass

func load_style_config(path: String):
	var file = File.new()
	file.open(path, File.READ)
	
	var fileName:String = path.get_file()
	var hide = false
	if fileName[0] == '~':
		fileName = fileName.replace("~", "")
		hide = true
	
	Globals.styleConfigs[fileName] = {
		"hidden" : hide,
		"data" : parse_json(file.get_as_text())
	}
	file.close()
	pass

func select_style(fileName: String):
	Globals.style = Globals.styleConfigs[fileName].data
	Globals.currentStyle = fileName
	pass

func display_style():
	if categoryBar == null || categoryBar.get_child_count() > 0:
		if not categoryBar == null:
			categoryBar.queue_free()
		categoryBar = categoryBarPrefab.instance()
		categoryContainer.add_child(categoryBar)
	
	for option in Globals.style:
		var mbtnInst = menuBtn.instance()
		categoryBar.add_child(mbtnInst)
	pass

func select_menu(index):
	Globals.windowIndex = index
	generate_window()
	pass

func generate_window():
	windowHeader.text = Globals.style[Globals.windowIndex].category
	# Delete existing nodes
	rebuild_entities_container()
	rebuild_entity_container(Globals.EntityWindow.DEFAULT)
	pass

func rebuild_entities_container():
	if entitiesCollectionContainer.get_child_count() > 0:
		entitiesCollectionContainer.queue_free()
	
	entitiesCollectionContainer = entitiesContainerPrefab.instance()
	entitiesContainer.add_child(entitiesCollectionContainer)
	
	# Generate new nodes
	var seshCategory = Session.data[Globals.windowIndex]
	for ent in seshCategory:
		# Generate a button
		var newViewBtn: Button = viewEntityBtn.instance()
		entitiesCollectionContainer.add_child(newViewBtn)
		newViewBtn.text = ent[0]["name"]
	
	# Generate an add entity button
	var aEBtn = newEntityBtn.instance()
	entitiesCollectionContainer.add_child(aEBtn)
	pass

func rebuild_entity_container(windowType: int):
	entityCollectionContainer.queue_free()
	
	assert(windowType in Globals.EntityWindow.values(), "The function argument is expected to be a Globals.EntityWindow index")
	match windowType:
		0:
			entityCollectionContainer = selectEntityWindowPrefab.instance()
			# Reset the attributables button to block adding data to null refs.
			AddAttributableBtn.disabled = true
			Globals.entityIndex = -1
		1:
			entityCollectionContainer = entityFreeformWindowPrefab.instance()
		2:
			#TODO:
			pass
	entityContainer.add_child(entityCollectionContainer)
	pass

func create_entry(windowIndex, btnIndex):
	print ("Creating entry in window: " + String(windowIndex))
	var dat = [{
		"name" : "Rename"
	}]
	Session.data[windowIndex].append(dat)
	rebuild_entities_container()
	view_entry(btnIndex)
	pass

func view_entry(index: int):
	Globals.entityIndex = index
	var windowName = Globals.style[Globals.windowIndex].window
	var windowConfig = Globals.windowConfigs[windowName]
	rebuild_entity_container(windowConfig.format)
	AddAttributableBtn.disabled = false
	AddAttributableBtn.get_popup().clear()
	for selector in windowConfig.fields:
		AddAttributableBtn.get_popup().add_icon_item(Functions.load_image(Globals.iconsPath + selector.icon), selector.prompt)
	pass

func on_attributable_selected(index: int):
	Globals.emit_signal(Globals.createEntityElementSignal, index)
	pass

func on_option_selected(index: int):
	match index:
		0: # Save
			if Session.savePath == "":
				saveAsDialogue.popup()
			else:
				Session.quick_save()
		1: # Save As
			saveAsDialogue.popup()
		#2: Seperator 
		3: # Load
			seshDialogue.popup()
		4: # New
			_on_NewButton_pressed()

func _on_SessionFileDialog_file_selected(path: String):
	load_existing_session(path)
	print("Loaded session: " + path.get_file())
	startOverlay.visible = false
	pass

func _on_NewButton_pressed():
	generate_style_options(false)
	pass

func generate_style_options(showHidden:bool):
	styleDialogue.clear()
	styleDialogue.add_separator("Select Style")
	if Globals.styleConfigs.size() == 0:
		var dir = Directory.new()
		if not dir.file_exists(Globals.cachePath + "config." + Globals.configExtension):
			parse_config(Globals.cacheDefault)
		else:
			var file = File.new()
			file.open(Globals.cachePath + "config." + Globals.configExtension, File.READ)
			parse_config(parse_json(file.get_as_text()))
			file.close()
	else:
		var id = 0
		for style in Globals.styleConfigs.keys():
			if not Globals.styleConfigs[style].hidden || showHidden:
				styleDialogue.add_item(style, id)
			id += 1
		styleDialogue.add_separator("Extras")
		if not showHidden:
			styleDialogue.add_item("Show Hidden", 4096)
		else:
			styleDialogue.add_item("Hide Hidden", 4095)
		styleDialogue.popup()
	pass

func _on_StyleFileDialogue_id_pressed(id):
	if id == 4096:
		yield(get_tree().create_timer(0.01), "timeout")
		generate_style_options(true)
		return
	elif id == 4095:
		yield(get_tree().create_timer(0.01), "timeout")
		generate_style_options(false)
		return
	
	var style = Globals.styleConfigs.keys()[id]
	select_style(style)
	start_new_session()
	startOverlay.visible = false
	pass

func _on_SaveSessionDialog_file_selected(path: String):
	print("saving: " + path)
	Session.sessionName = path.get_file()
	Session.save_data(path)
	Functions.set_app_name()
	pass

func handle_redraw_all(windowOffset:Vector2):###
	generate_window()
	pass

func context_menu_request(requesteeNode):
	requesteeNode.handle_popup(nodeContextMenu)

func disconnect_from_context_menu(requesteeNode, connectedTo, functionToDisconnect):
	nodeContextMenu.disconnect(connectedTo, requesteeNode, functionToDisconnect)

func node_rename_dialogue_request(nodeIndex, nodeTitle, position):
	nodeRenameInput.text = nodeTitle
	nodeRenameDialogue.currentIndex = nodeIndex
	nodeRenameDialogue.set_position(position)
	nodeRenameDialogue.popup()
	nodeRenameInput.grab_focus()

func _on_NodeRenameDialogue_confirmed():
	var entityData = Session.get_current_entity()
	entityData[nodeRenameDialogue.currentIndex].header = nodeRenameInput.text
	Globals.emit_signal(Globals.refreshNodeSignal)
	pass

func assign_file_finder(filterArray, access, mode, dialogue, title):
	fileFinderDialogue.filters = filterArray
	fileFinderDialogue.access = access
	fileFinderDialogue.mode = mode
	fileFinderDialogue.dialog_text = dialogue
	fileFinderDialogue.window_title = title
	fileFinderDialogue.popup()
	pass

