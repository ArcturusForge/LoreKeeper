extends Control

# Vars
onready var categoryBar = $Control/ScrollContainer/CategoryBar
onready var windowHeader = $HSplitContainer/ColorRect/WindowHeader
onready var entitiesContainer = $HSplitContainer/ColorRect/EntitiesContainer
onready var entityContainer = $HSplitContainer/ColorRect2/EntityContainer

# Dynamics
var entitiesCollectionContainer
var entityCollectionContainer

# Prefabs
onready var menuBtn = preload("res://Prefabs/MenuBtn.tscn")
onready var collectionContainer = preload("res://Prefabs/collectionContainer.tscn")
onready var newEntityBtn = preload("res://Prefabs/AddEntityBtn.tscn")
onready var viewEntityBtn = preload("res://Prefabs/ViewEntityBtn.tscn")

func _ready():
	entitiesCollectionContainer = $HSplitContainer/ColorRect/EntitiesContainer/collectionContainer
	entityCollectionContainer = $HSplitContainer/ColorRect2/EntityContainer/collectionContainer
	
	#TODO: Prompt session loader
	#TEMP:
	start_new_session()
	pass

func start_new_session():
	Globals.connect(Globals.menuSelectedSignal, self, "select_menu")
	Globals.check_folder_integrity()
	
	#TODO: Rip this out and do a style selector
	var dir = Directory.new()
	if not dir.file_exists(Globals.cachePath + "/config." + Globals.configExtension):
		Globals.create_style_default()
		parse_cache(Globals.cacheDefault)
	else:
		var file = File.new()
		file.open(Globals.cachePath + "/config." + Globals.configExtension, File.READ)
		parse_cache(parse_json(file.get_as_text()))
		file.close()
	
	#TODO: Session data
	Session.sessionName = "Untitled_Session"
	Session.styleUsed = Globals.currentStyle
	for index in Globals.style.size():
		Session.data[index] = []
	
	Session.data[0] = [
		{
			"name" : "Bob Rimly"
		}
	]
	#		  category-\/  \/-index of entity
	#print(Session.data[0][0].name)
	
	display_style()
	pass

func parse_cache(data):
	# Check for defined style
	Globals.check_defaults_integrity()
	
	# Locate and iterate over every element type
	var elements = Functions.get_all_files(Globals.elementsPath, Globals.elementExtension)
	for element in elements:
		load_element(element)
	
	# Locate and iterate over every window type
	var windows = Functions.get_all_files(Globals.windowsPath, Globals.windowExtension)
	for window in windows:
		load_window(window)

	var dir = Directory.new()
	if not dir.file_exists(Globals.stylesPath + "/" + data.style):
		Globals.check_defaults_integrity()
		load_style(Globals.stylesPath + "/Default." + Globals.styleExtension)
	else:
		# Load the set style
		load_style(Globals.stylesPath + "/" + data.style)
	pass

func load_element(path):
	pass #TODO:

func load_window(path):
	pass #TODO:

func load_style(path: String):
	var file = File.new()
	file.open(path, File.READ)
	Globals.style = parse_json(file.get_as_text())	
	Globals.currentStyle = path.get_file()
	file.close()

func display_style():
	for option in Globals.style:
		var mbtnInst = menuBtn.instance()
		categoryBar.add_child(mbtnInst)

func select_menu(index):
	Globals.windowIndex = index
	generate_window()

func generate_window():
	windowHeader.text = Globals.style[Globals.windowIndex].category
	
	# Delete existing nodes
	if entitiesCollectionContainer.get_child_count() > 0:
		entitiesCollectionContainer.queue_free()
	if entityCollectionContainer.get_child_count() > 0:
		entityCollectionContainer.queue_free()
	
	# Generate new nodes
	entitiesCollectionContainer = collectionContainer.instance()
	entitiesContainer.add_child(entitiesCollectionContainer)
	#TODO: read session data and load entities
	var seshCategory = Session.data[Globals.windowIndex]
	var entIndex = -1
	for ent in seshCategory:
		entIndex += 1
		# Generate a button
		var newViewBtn: Button = viewEntityBtn.instance()
		entitiesCollectionContainer.add_child(newViewBtn)
		newViewBtn.text = ent.name
		#TODO: Tie in a view function on click event
	
	# Generate an add entity button
	var aEBtn = newEntityBtn.instance()
	entitiesCollectionContainer.add_child(aEBtn)
	#TODO: Tie in a create function on click event
	
	entityCollectionContainer = collectionContainer.instance()
	entityContainer.add_child(entityCollectionContainer)
	#TODO: select first entity and preview it as default
	pass
