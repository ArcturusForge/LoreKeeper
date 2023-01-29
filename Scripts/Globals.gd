extends Node

# Paths
var dataPath = "res://AppData/" #OR
#var dataPath = "user://AppData/"
var cachePath = dataPath + "Cache/"
var elementsPath = dataPath + "Elements/"
var stylesPath = dataPath + "Styles/"
var windowsPath = dataPath + "Windows/"
var iconsPath = dataPath + "Icons/"

# Constants
const configExtension = "lki"
const elementExtension = "lke"
const windowExtension = "lkw"
const styleExtension = "lks"
const saveExtension = "lore"
const sessionNameDefault = "Untitled_Session"

# Element Prefabs
const hContainerPrefab = preload("res://Prefabs/ElementPrefabs/HContainerElement.tscn")
const spritePrefab = preload("res://Prefabs/ElementPrefabs/SpriteElement.tscn")

# Enums
enum EntityWindow {DEFAULT, FREEFORM, GRAPH}

# Defaults
var cacheDefault = {
	"style" : "Default." + styleExtension
}

var styleDefault = [
	{
		"category": "Characters",
		"window": "Character_(collection).lkw",
		"icon": "pawn.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Factions",
		"window": "Character_(collection).lkw",
		"icon": "crown_a.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Locations",
		"window": "Character_(collection).lkw",
		"icon": "flag_square.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Items",
		"window": "Character_(collection).lkw",
		"icon": "pouch.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Concepts",
		"window": "Character_(collection).lkw",
		"icon": "puzzle.png",
		"addIcon": "card_add.png"
	}
]

var characterWindowDefault = {
  "format" : 1,
  "fields" : [
	{
	  "prompt" : "Add General Info",
	  "icon" : "notepad_write.png",
	  "header" : "General Info",
	  "description" : "Create and set general traits",
	  "asList" : true,
	  "type" : "Trait.lke",
	  "listPrompt" : "Add Trait"
	},
	{
	  "prompt" : "Add Description",
	  "icon" : "book_closed.png",
	  "header" : "Description",
	  "description" : "Set charater description",
	  "asList" : false,
	  "type" : "Text.lke"
	},
	{
	  "prompt" : "Add Gallery",
	  "icon" : "pawns.png",
	  "header" : "Gallery",
	  "description" : "Set charater images",
	  "asList" : true,
	  "type" : "Image.lke",
	  "listPrompt" : "Add Image"
	}
  ]
}

var imageAttributeDefault = {
	"construct" : ["sprite"],
	"seperatorInterval" : 0,
	"seperator" : ""
}

var traitAttributeDefault = {
	"construct" : ["string", "string"],
	"seperatorInterval" : 1,
	"seperator" : " : "
}

# Data
var style = {} # Data for the current style
var currentStyle: String # Name of the current style
var windowIndex = -1
var entityIndex = -1

var styleConfigs = {}
var windowConfigs = {}
var elementConfigs = {}

# Global Signals
# Called when a category button is pressed.
signal on_menu_selected(categoryIndex)
var menuSelectedSignal = "on_menu_selected"
# Called when a new entity is created.
signal on_create_entry(windowIndex, entityIndex)
var createEntrySignal = "on_create_entry"
# Called when an entity button is pressed.
signal on_view_entry(entityIndex)
var viewEntrySignal = "on_view_entry"
# Called when the user creates an element inside an entity.
signal create_entity_element(elementIndex)
var createEntityElementSignal = "create_entity_element"
# Called to repaint the entities list.
signal repaint_entities()
var repaintEntitiesSignal = "repaint_entities"
# Called to redraw the entity/ies ui.
signal redraw_all()
var redrawAllSignal = "redraw_all"
# Called to request a file finder.
signal request_file_finder(filterArray, access, mode, dialogue, title)
var requestFileFinder = "request_file_finder"
# Called when a file finder has selected files.
# Ensure listener is disconnected after receiving data.
signal receive_file_finder(paths)
var receiveFileFinder = "receive_file_finder"

# Node Signals
# Called whenever a node is deleted.
signal closing_node(nodeIndex)
var closeNodeSignal = "closing_node"
# Called whenever a node is resized.
signal resizing_node(nodeIndex, newSize)
var resizeNodeSignal = "resizing_node"
# Called whenever a node is repositioned.
signal repositioning_node(nodeIndex, newPosition)
var repositionNodeSignal = "repositioning_node"
# Called whenver a context-menu request is made.
signal requesting_context_menu(nodeIndex, menuPosition)
var requestContextMenuSignal = "requesting_context_menu"
# Called whenver a change was made to a node
signal refreshing_node()
var refreshNodeSignal = "refreshing_node"

# Functions
func set_default_style(name):
	cacheDefault["style"] = name + "." + styleExtension
	pass

func check_folder_integrity():
	var dir = Directory.new()
	if not dir.dir_exists(Functions.os_path_convert(dataPath)):
		dir.make_dir(Functions.os_path_convert(dataPath))
		dir.make_dir(Functions.os_path_convert(cachePath))
		dir.make_dir(Functions.os_path_convert(elementsPath))
		dir.make_dir(Functions.os_path_convert(windowsPath))
		dir.make_dir(Functions.os_path_convert(stylesPath))
		dir.make_dir(Functions.os_path_convert(iconsPath))
		return
	
	if not dir.dir_exists(Functions.os_path_convert(cachePath)):
		dir.make_dir(Functions.os_path_convert(cachePath))
	
	if not dir.dir_exists(Functions.os_path_convert(elementsPath)):
		dir.make_dir(Functions.os_path_convert(elementsPath))
	
	if not dir.dir_exists(Functions.os_path_convert(windowsPath)):
		dir.make_dir(Functions.os_path_convert(windowsPath))
	
	if not dir.dir_exists(Functions.os_path_convert(stylesPath)):
		dir.make_dir(Functions.os_path_convert(stylesPath))
	pass

func check_defaults_integrity():
	var dir = Directory.new()
	# Generate the default style files
	if not dir.file_exists(Functions.os_path_convert(cachePath) + "config." + configExtension):
		var file = File.new()
		file.open(Functions.os_path_convert(cachePath) + "config." + configExtension, File.WRITE)
		file.store_line(to_json(cacheDefault))
		file.close()
	
	# Generate the default style files
	if not dir.file_exists(Functions.os_path_convert(stylesPath) + "Default." + styleExtension):
		var file = File.new()
		file.open(Functions.os_path_convert(stylesPath) + "Default." + styleExtension, File.WRITE)
		file.store_line(to_json(styleDefault))
		file.close()
	
	# Generate the default windows files
	if not dir.file_exists(Functions.os_path_convert(windowsPath) + "Character_(collection)." + windowExtension):
		var file = File.new()
		file.open(Functions.os_path_convert(windowsPath) + "Character_(collection)." + windowExtension, File.WRITE)
		file.store_line(to_json(characterWindowDefault))
		file.close()
	
	# Generate the default element files
	if not dir.file_exists(Functions.os_path_convert(elementsPath) + "Image." + elementExtension):
		var file = File.new()
		file.open(Functions.os_path_convert(elementsPath) + "Image." + elementExtension, File.WRITE)
		file.store_line(to_json(characterWindowDefault))
		file.close()
	pass

func get_current_window():
	var windowName = style[windowIndex].window
	return windowConfigs[windowName]
