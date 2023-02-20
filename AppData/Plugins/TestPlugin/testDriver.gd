extends Control
# Assigned by the plugin manager when loaded in. 
# (Value changes every time the plugin is loaded)
var activePluginId

# Return false if you are not using the _run() loop.
func _do_run():
	return false

# Called by the plugin manager when plugin loaded.
func _configure():
	print("configuring plugin")
	pass

# Called by the plugin manager every frame.
func _run():
	pass

# Called by the plugin manager when the plugin is unloaded.
func _unload():
	print("unloading plugin")
	pass
