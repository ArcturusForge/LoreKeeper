extends Control

# Assigned by the plugin manager when loaded in. 
# (Value changes every time the plugin is loaded)
var activePluginId

# Assigned by the plugin manager when loaded in. 
# Points to your plugin folder.
var pluginPath

var overlay

# Return false if you are not using the _run() loop.
func _do_run():
	return false

# Called by the plugin manager when plugin loaded.
func _configure():
	print("plugin is loaded")
	
	overlay = load(pluginPath + "/Scenes/HelloWorldOverlay.tscn").instance()
	overlay.visible = false
	Globals.main.add_child(overlay)
	
	var optionsPopup = Globals.main.optionsBtn
	optionsPopup.define_entity(str(activePluginId), self, "handle_option_select")
	optionsPopup.add_separator(str(activePluginId), "Hello World Plugin")
	optionsPopup.add_option(str(activePluginId), "Open")
	pass

# Called by the plugin manager every frame.
func _run():
	pass

# Called by the plugin manager when the plugin is unloaded.
func _unload():
	var optionsPopup = Globals.main.optionsBtn
	optionsPopup.remove_entity(str(activePluginId))
	
	overlay.queue_free()
	pass

func handle_option_select(option):
	match option:
		"Open":
			print("Plugin option pressed")
			overlay.visible = true
	pass
