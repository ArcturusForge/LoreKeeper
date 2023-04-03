extends Control

#-- Constants
const my_id = "popups"

#-- Scene Refs
onready var optionsBtn = $"../../Control/FileOptionsButton"

#-- Dynamic Vars
var popupRegistries = {}

#--- Functions
func jump_start():
	Globals.set_manager(my_id, self)
	register_popup("optionMenu", optionsBtn.get_popup())
	pass

func register_popup(name, popup):
	if not popupRegistries.has(name):
		var pData = Globals.popupDataScript.new()
		pData.construct(popup)
		popupRegistries[name] = pData
	pass

func remove_popup(name):
	if popupRegistries.has(name):
		popupRegistries.erase(name)
	pass

func get_popup_data(name):
	if popupRegistries.has(name):
		return popupRegistries[name]
	return null
