extends Node

#-- Control
const versionId = "1.0.0"
const appName = "LoreKeeper"
const sessionNameDefault = "Untitled_Session"
const saveExtension = "lore"

var main
var plugins

#-- Paths
var resDataPath = "res://App/"
var userDataPath = "user://"
var cachePath = "Cache/"
var elementsPath = "Custom/Elements/"
var stylesPath = "Custom/Styles/"
var windowsPath = "Custom/Windows/"
var iconsPath = "Graphics/Icons/"
var pluginsPath = "Plugins/"

# Constants
const configExtension = "lki"
const elementExtension = "lke"
const windowExtension = "lkw"
const styleExtension = "lks"
const pluginExtension = "lkp"

#- Scripts
var popupDataScript = preload("res://Scripts/Generics/PopupData.gd")

# Element Prefabs
const elementSegmentPrefab = preload("res://Prefabs/ElementPrefabs/ElementSegmentContainer.tscn")
const elementListBtnPrefab = preload("res://Prefabs/ElementPrefabs/AddListedElementButton.tscn")
const elementSeperatorPrefab = preload("res://Prefabs/ElementPrefabs/ElementSeperator.tscn")

# Plugin Prefabs
const pluginOptionPrefab = preload("res://Prefabs/PluginOption.tscn")

# Enums
enum EntityWindow {DEFAULT, FREEFORM, GRAPH}

#-- Globalizer
var managers = {}

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
func _ready():
	#- Makes sure the game extensions folder exists.
	Functions.ensure_directory(userDataPath + cachePath)
	Functions.ensure_directory(userDataPath + pluginsPath)
	pass

#--- Repaints the app's name to indicate whether save worthy changes have been made to the session
func repaint_app_name(needsSaving:bool = false):
	if not needsSaving:
		OS.set_window_title(Globals.appName + "_" + Globals.versionId + " - " + Session.sessionName)
	else:
		OS.set_window_title(Globals.appName + "_" + Globals.versionId + " - " + Session.sessionName + " (*)")
	pass

func set_manager(name:String, manager):
	if managers.has(name):
		printerr("Overwriting an existing manager")
		return
	managers[name] = manager

func get_manager(name:String):
	if managers.has(name):
		return managers[name]
	return null

func get_current_window():
	var windowName = style[windowIndex].window
	return windowConfigs[windowName]
