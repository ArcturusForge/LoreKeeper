extends Control

var detectedPlugins = {}
var loadedPlugins = {}
var runIds = []

onready var pluginContainer = $"../../PluginContainer"

func _ready():
	_detect_plugins()
	pass

func _process(delta):
	for i in range(0, runIds.size()):
		loadedPlugins[runIds[i]]._run()
	pass

# Detects and compiles all plugins within the plugin folder.
func _detect_plugins():
	var detected = Functions.get_all_files(Globals.pluginsPath, Globals.pluginExtension)
	for plugin in detected:
		var file = File.new()
		file.open(plugin, File.READ)
		var config = parse_json(file.get_as_text())
		file.close()
		
		var uniqueId = Functions.generate_id()
		while detectedPlugins.keys().has(uniqueId):
			uniqueId = Functions.generate_id()
		
		detectedPlugins[uniqueId] = {
			"id" : uniqueId,
			"config" : config,
			"path" : plugin.get_base_dir()
		}
		print("detected plugin : " + config.name)
	pass

# Activates and registers a plugin.
func _load_plugin(id: int):
	var plugin = detectedPlugins[id]
	var driver = Functions.get_prefab(plugin.path + "/" + plugin.config.driver)
	pluginContainer.add_child(driver)
	loadedPlugins[id] = driver
	if driver._do_run():
		runIds.append(id)
	driver.activePluginId = id
	driver._configure()
	pass

# Deactivates a loaded plugin.
func _unload_plugin(id: int):
	var driver = loadedPlugins[id]
	driver._unload()
	driver.queue_free()
	pass

# Generates the overall plugin selection window.
func _generate_plugin_menu():
	# TODO: Make icon about app version mismatching
	pass

# Generates the preview of a single plugin.
func _generate_plugin_preview():
	# TODO: Make notice about app version mismatching
	pass

# - folder structure: AppData/Plugins/[plugin name]/[config name].lkp
# - handshake protocol: json config
# Contains:
# - name
# - description
# - icon
# - driver prefab
