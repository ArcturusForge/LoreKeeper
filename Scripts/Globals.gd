extends Node

# Control
const versionId = "0.1.3"

var main
var plugins

# Paths
var dataPath = "res://AppData/" #OR
#var dataPath = "user://AppData/"
var cachePath = dataPath + "Cache/"
var elementsPath = dataPath + "Custom/Elements/"
var stylesPath = dataPath + "Custom/Styles/"
var windowsPath = dataPath + "Custom/Windows/"
var iconsPath = dataPath + "Icons/"
var pluginsPath = dataPath + "Plugins/"

# Constants
const configExtension = "lki"
const elementExtension = "lke"
const windowExtension = "lkw"
const styleExtension = "lks"
const saveExtension = "lore"
const pluginExtension = "lkp"
const appName = "LoreKeeper"
const sessionNameDefault = "Untitled_Session"

# Element Prefabs
const elementSegmentPrefab = preload("res://Prefabs/ElementPrefabs/ElementSegmentContainer.tscn")
const elementListBtnPrefab = preload("res://Prefabs/ElementPrefabs/AddListedElementButton.tscn")
const elementSeperatorPrefab = preload("res://Prefabs/ElementPrefabs/ElementSeperator.tscn")

# Plugin Prefabs
const pluginOptionPrefab = preload("res://Prefabs/PluginOption.tscn")

# Enums
enum EntityWindow {DEFAULT, FREEFORM, GRAPH}

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
signal requesting_context_menu(requesteeNode)
var requestContextMenuSignal = "requesting_context_menu"
# Called whenver a node rename request is made.
signal requesting_node_rename(nodeIndex, nodeTitle, nodePosition)
var requestNodeRenameSignal = "requesting_node_rename"
# Called whenever a disconnect-from-context-menu request is made.
signal disconnecting_context_menu(requesteeNode, connectedTo, functionToDisconnect)
var disconnectContextMenuSignal = "disconnecting_context_menu"
# Called whenver a change was made to a node.
signal refreshing_node()
var refreshNodeSignal = "refreshing_node"

# Element Signals
# Called whenver an element is added to a node.
signal adding_element(nodeIndex, listParent, newElementIndex)
var addElementSignal = "adding_element"
# Called whenver an element is removed from a node.
signal removing_element(nodeIndex)
var removeElementSignal = "removing_element"

# Functions
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
	# Generate the default style files
	check_and_create(cachePath + "Cache." + configExtension, Defaults.get_cache_default())
	
	# Generate the default style files
	check_and_create(stylesPath + "Default." + styleExtension, Defaults.styleDefault)
	
	# Generate the default windows files
	check_and_create(windowsPath + "Character_(collection)." + windowExtension, Defaults.characterWindowDefault)
	
	# Generate the default element files
	check_and_create(elementsPath + "Image." + elementExtension, Defaults.imageAttributeDefault)
	check_and_create(elementsPath + "Trait." + elementExtension, Defaults.traitAttributeDefault)
	check_and_create(elementsPath + "LargeText." + elementExtension, Defaults.lTextAttributeDefault)
	check_and_create(elementsPath + "SmallText." + elementExtension, Defaults.sTextAttributeDefault)
	pass

func check_and_create(path, data):
	var dir = Directory.new()
	if not dir.file_exists(path):
		if Functions.is_app():
			Defaults.generate(Functions.os_path_convert(path), data)
		else:
			Defaults.generate(path, data)
	pass

func get_current_window():
	var windowName = style[windowIndex].window
	return windowConfigs[windowName]
