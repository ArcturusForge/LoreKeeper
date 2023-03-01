extends Control

# Assigned by the plugin manager when loaded in. 
# (Value changes every time the plugin is loaded)
var activePluginId

# Return false if you are not using the _run() loop.
func _do_run():
	return false

# Called by the plugin manager when plugin loaded.
func _configure():
	print("plugin is loaded")
	var optionsPopup = Globals.main.optionsBtn
	optionsPopup.define_entity(str(activePluginId), self, "handle_popup")
	optionsPopup.add_option(str(activePluginId), "Test1")
	pass

# Called by the plugin manager every frame.
func _run():
	pass

# Called by the plugin manager when the plugin is unloaded.
func _unload():
	var optionsPopup = Globals.main.optionsBtn
	optionsPopup.remove_option(str(activePluginId), "Test1")
	pass

func handle_popup(option):
	match option:
		"Test1":
			print("Plugin option pressed")
	pass
