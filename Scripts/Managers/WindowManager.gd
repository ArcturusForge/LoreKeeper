extends Control

#-- Constants
const my_id = "window"

#-- Window Parent
#onready var windows_parent = 

#-- Enabled on all window activation.
onready var input_block = null

#-- Scene Refs


#-- Windows
var windows = {}

#-- Dynamic Vars
var activeWindow

func jump_start():
	Globals.set_manager(my_id, self)
	
	#- Register all local windows.
	#register_window("", )
	
	#- Disable any active windows on boot.
	for window in windows.values():
		window.visible = false
	pass

func activate_window(windowId, data=null):
	if windows.has(windowId):
		input_block.visible = true
		disable_window(false)
		activeWindow = windows[windowId]
		activeWindow.visible = true
		activeWindow._enable(data)
	pass

func disable_window(disableBlock = true):
	if not activeWindow == null:
		if disableBlock:
			disable_input_block()
		activeWindow._disable()
		activeWindow.visible = false
		activeWindow = null
	pass

func disable_input_block():
	input_block.visible = false
	pass

func register_window(id, window, defaultState = false):
	window.window_manager = self
	window._create()
	windows[id] = window
	if defaultState == true:
		activate_window(id)
	else:
		window.visible = false
	pass
