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
	  "header" : "General Info",
	  "description" : "Create and set general traits",
	  "asList" : true,
	  "type" : "Trait.lke",
	  "prompt" : "Add Trait"
	},
	{
	  "header" : "Description",
	  "description" : "Set charater description",
	  "asList" : false,
	  "type" : "Text.lke"
	},
	{
	  "header" : "Gallery",
	  "description" : "Set charater images",
	  "asList" : true,
	  "type" : "Image.lke",
	  "prompt" : "Add Image"
	}
  ],
  "selections" : [
	{
		"Prompt" : "Add General Info",
		"fieldIndex" : 0
	},
	{
		"Prompt" : "Add Description",
		"fieldIndex" : 1
	},
	{
		"Prompt" : "Add Gallery",
		"fieldIndex" : 2
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
# Called when a ui button is pressed and before ui is turned on.
# Receives a ui wipedown value that determines what ui regions need to be disabled.
signal ui_button_clicked(value1)
var uiButtonClicked = "ui_button_clicked"

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
