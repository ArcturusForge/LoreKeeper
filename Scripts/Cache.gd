extends Node

var bgData = ""
var bgExtension = ""
var activePlugins = []

func save_cache():
	var path = Globals.cachePath + "Cache.lki"
	if Functions.is_app():
		path = Functions.os_path_convert(path)
	
	var compilation = {
		"bg" : bgData,
		"extension" : bgExtension,
		"plugins" : activePlugins
	}
	
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(compilation))
	file.close()
	pass

func load_cache():
	var file = File.new()
	if Functions.is_app():
		file.open(Functions.os_path_convert(Globals.cachePath + "Cache.lki"), File.READ)
	else:
		file.open(Globals.cachePath + "Cache.lki", File.READ)
	var cache = parse_json(file.get_as_text())
	file.close()
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
