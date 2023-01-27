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

# Enums
enum EntityWindow {DEFAULT, LIST, FREEFORM, GRAPH}
enum WipedownUI {All, LEFT, MIDDLE, RIGHT}

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
var style = {}
var currentStyle
var windowIndex = -1
var entityIndex = -1

var windowConfigs = {}
var elementConfigs = {}

# Signals
# Called when a category button is pressed.
# Receives the category index.
signal on_menu_selected(value1)
var menuSelectedSignal = "on_menu_selected"
# Called when a new entity is created.
# Receives window and the new entry index.
signal on_create_entry(value1, value2)
var createEntrySignal = "on_create_entry"
# Called when an entity button is pressed.
# Receives the etity index.
signal on_view_entry(value1)
var viewEntrySignal = "on_view_entry"
# Called when the user creates an element inside an entity.
# Receives the element index.
signal create_entity_element(value1)
var createEntityElementSignal = "create_entity_element"
# Called to repaint the entities list.
# Receives no data.
signal repaint_entities()
var repaintEntitiesSignal = "repaint_entities"

# Functions
func set_default_style(name):
	cacheDefault["style"] = name + "." + styleExtension

func check_folder_integrity():
	var dir = Directory.new()
	if not dir.dir_exists(Functions.os_path_convert(dataPath)):
		dir.make_dir(Functions.os_path_convert(dataPath))
		dir.make_dir(Functions.os_path_convert(cachePath))
		dir.make_dir(Functions.os_path_convert(elementsPath))
		dir.make_dir(Functions.os_path_convert(windowsPath))
		dir.make_dir(Functions.os_path_convert(stylesPath))
		dir.make_dir(Functions.os_path_convert(iconsPath))
		#TEMP:
		dir.make_dir(Functions.os_path_convert("res://AppData/Saves/"))
		pass
	
	if not dir.dir_exists(Functions.os_path_convert(cachePath)):
		dir.make_dir(Functions.os_path_convert(cachePath))
	
	if not dir.dir_exists(Functions.os_path_convert(elementsPath)):
		dir.make_dir(Functions.os_path_convert(elementsPath))
	
	if not dir.dir_exists(Functions.os_path_convert(windowsPath)):
		dir.make_dir(Functions.os_path_convert(windowsPath))
	
	if not dir.dir_exists(Functions.os_path_convert(stylesPath)):
		dir.make_dir(Functions.os_path_convert(stylesPath))

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
