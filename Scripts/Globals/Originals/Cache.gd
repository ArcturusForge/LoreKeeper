extends Node

var bgData = ""
var bgExtension = ""
var activePlugins = []

func save_cache():
	var path = Globals.userDataPath + Globals.cachePath + "Cache.lki"
	
	var compilation = {
		"bg" : bgData,
		"extension" : bgExtension,
		"plugins" : activePlugins
	}
	
	Functions.write_file(compilation, path)
	pass

func load_cache():
	var path = Globals.userDataPath + Globals.cachePath + "Cache.lki"
	if not Functions.file_exists(path):
		path = Globals.resDataPath + Globals.cachePath + "Cache.lki"
		print("Using local cache...")
	
	var cache = Functions.read_file(path)
	bgData = cache.bg
	bgExtension = cache.extension
	activePlugins = cache.plugins
	pass

func add_plugin(pluginName):
	if not activePlugins.has(pluginName):
		activePlugins.append(pluginName)
	pass

func remove_plugin(pluginName):
	if activePlugins.has(pluginName):
		activePlugins.erase(pluginName)
	pass
