extends Control

# Vars
onready var startOverlay = $StartOverlay
onready var seshDialogue: FileDialog = $SessionFileDialog
onready var styleDialogue: PopupMenu = $StyleFileDialogue
onready var saveAsDialogue: FileDialog = $SaveSessionDialog

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
	
	# Global event signal subscription
	Globals.connect(Globals.menuSelectedSignal, self, "select_menu")
	Globals.connect(Globals.createEntrySignal, self, "create_entry")
	Globals.connect(Globals.viewEntrySignal, self, "view_entry")
	Globals.connect(Globals.redrawAllSignal, self, "handle_redraw_all")
	
	# Local event signal subscription
	AddAttributableBtn.get_popup().connect("id_pressed", self, "on_attributable_selected")
	OptionsBtn.get_popup().connect("id_pressed", self, "on_option_selected")
	
	# Check for directory and defaults integrity
	Globals.check_folder_integrity()
	Globals.check_defaults_integrity()
	
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
	
	#TODO: Prompt session loader
	#TEMP:
	#start_new_session()
	#load_existing_session("res://AppData/Saves/Untitled_Session.lore")
	pass

func load_existing_session(path: String):
	Session.load_data(path)
	select_style(Session.styleUsed)
	display_style()
	pass

func start_new_session():
	Session.reset_data()
	
	Session.styleUsed = Globals.currentStyle
	for index in Globals.style.size():
		var dat = []
		Session.data.append(dat)
	
	display_style()
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
	pass #TODO:

func load_window_config(path: String):
	var file = File.new()
	file.open(path, File.READ)
	Globals.windowConfigs[path.get_file()] = parse_json(file.get_as_text())
	file.close()
	pass

func load_style_config(path: String):
	var file = File.new()
	file.open(path, File.READ)
	Globals.styleConfigs[path.get_file()] = parse_json(file.get_as_text())
	file.close()
	pass

func select_style(fileName: String):
	Globals.style = Globals.styleConfigs[fileName]
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
		#TODO: Tie in a view function on click event
	
	# Generate an add entity button
	var aEBtn = newEntityBtn.instance()
	entitiesCollectionContainer.add_child(aEBtn)
	pass

func rebuild_entity_container(windowType: int):
	if entityCollectionContainer.get_child_count() > 0:
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
	var windowName = Globals.style[Globals.windowIndex].window
	var windowConfig = Globals.windowConfigs[windowName]
	var option = windowConfig.fields[index]
	print(option.header)
	Session.data[Globals.windowIndex][Globals.entityIndex].append({
		"header" : option.header,
		"fieldIndex" : index,
		"data" : []
	})
	
	#TODO: Create element in scene
	Globals.emit_signal(Globals.createEntityElementSignal, index)
	pass

func on_option_selected(index: int):
	# TODO: add a save as option
	match index:
		0: # Save
			#Session.save_data("res://AppData/Saves/")
			#print("Saved session: " + Session.sessionName)
			if Session.savePath == "":
				saveAsDialogue.popup()
			else:
				Session.quick_save()
		1: # Load
			seshDialogue.popup()
		2: # New
			_on_NewButton_pressed()

func _on_SessionFileDialog_file_selected(path: String):
	load_existing_session(path)
	print("Loaded session: " + path.get_file())
	startOverlay.visible = false
	pass

func _on_NewButton_pressed():
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
		for style in Globals.styleConfigs.keys():
			styleDialogue.add_item(style)
		styleDialogue.popup()
	pass

func _on_StyleFileDialogue_index_pressed(index):
	index -= 1
	var style = Globals.styleConfigs.keys()[index]
	select_style(style)
	start_new_session()
	startOverlay.visible = false
	pass

func _on_SaveSessionDialog_file_selected(path: String):
	print("saving: " + path)
	Session.sessionName = path.get_file()
	Session.save_data(path)
	pass

func handle_redraw_all():
	generate_window()
	pass
