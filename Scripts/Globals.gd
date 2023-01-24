extends Node

# Paths
var dataPath = "res://AppData/"
var cachePath = dataPath + "/Cache"
var elementsPath = dataPath + "/Elements"
var stylesPath = dataPath + "/Styles"
var windowsPath = dataPath + "/Windows"
var iconsPath = dataPath + "/Icons"

# Constants
const configExtension = "lki"
const elementExtension = "lke"
const windowExtension = "lkw"
const styleExtension = "lks"
const saveExtension = "lore"

# Enums
enum EntityWindow {SELECTOR, VERTICAL, FREEFORM, GRAPH}

# Defaults
var cacheDefault = {
	"style" : "Default." + styleExtension
}

var styleDefault = [
	{
		"category": "Characters",
		"window": "Character_(collection)",
		"icon": null
	},
	{
		"category": "Factions",
		"window": "",
		"icon": null
	},
	{
		"category": "Locations",
		"window": "",
		"icon": null
	},
	{
		"category": "Items",
		"window": "",
		"icon": null
	},
	{
		"category": "Concepts",
		"window": "",
		"icon": null
	}
]

var characterWindowDefault = {
	"style" : "collection",
	"fields" : [
		{
			"header" : "General Info",
			"description" : "Create and set general traits",
			"type" : "list",
			"prompt" : "Add Trait",
			"element" : "Trait"
		},
		{
			"header" : "Description",
			"description" : "Set charater images",
			"type" : "string"
		},
		{
			"header" : "Profile",
			"description" : "Set charater images",
			"type" : "list",
			"prompt" : "Add Image",
			"element" : "Image"
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

# Signals
signal on_menu_selected(value1)
var menuSelectedSignal = "on_menu_selected"
signal on_create_entry(value1, value2)
var createEntrySignal = "on_create_entry"
signal on_view_entry(value1)
var viewEntrySignal = "on_view_entry"

# Functions
func set_default_style(name):
	cacheDefault["style"] = name + "." + styleExtension

func create_elements_default(): #TODO:
	pass
	

func create_windows_default(): #TODO:
	pass
	

func check_folder_integrity():
	var dir = Directory.new()
	if not dir.dir_exists(cachePath):
		dir.make_dir(cachePath)
	
	if not dir.dir_exists(elementsPath):
		dir.make_dir(elementsPath)
	
	if not dir.dir_exists(windowsPath):
		dir.make_dir(windowsPath)
	
	if not dir.dir_exists(stylesPath):
		dir.make_dir(stylesPath)

func check_defaults_integrity():
	var dir = Directory.new()
	# Generate the default style files
	if not dir.file_exists(stylesPath + "/Default." + styleExtension):
		var file = File.new()
		file.open(stylesPath + "/Default." + styleExtension, File.WRITE)
		file.store_line(to_json(styleDefault))
		file.close()
	
	# Generate the default windows files
	if not dir.file_exists(windowsPath + "/Character_(collection)." + windowExtension):
		var file = File.new()
		file.open(windowsPath + "/Character_(collection)." + windowExtension, File.WRITE)
		file.store_line(to_json(characterWindowDefault))
		file.close()
	
	# Generate the default element files
	if not dir.file_exists(windowsPath + "/Image." + elementExtension):
		var file = File.new()
		file.open(windowsPath + "/Image." + windowExtension, File.WRITE)
		file.store_line(to_json(characterWindowDefault))
		file.close()
