extends Control

var detectedPlugins = {}
var loadedPlugins = {}
var runIds = []

onready var pluginContainer = $"../../PluginContainer"
onready var plugin_overlay = $"../../PluginOverlay"
onready var option_container = $"../../PluginOverlay/SelectorBg/VBoxContainer/OptionContainer"
# Plugin Preview
onready var header_label = $"../../PluginOverlay/SelectorBg/Preview/HeaderLabel"
onready var preview_texture = $"../../PluginOverlay/SelectorBg/Preview/PreviewTexture"
onready var description_label = $"../../PluginOverlay/SelectorBg/Preview/DescriptionLabel"

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
		
		var uniqueId :int = Functions.generate_id()
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
	loadedPlugins.erase(id)
	if runIds.has(id):
		runIds.erase(id)
	driver._unload()
	driver.queue_free()
	pass

# Generates the overall plugin selection window.
func _generate_plugin_menu():
	# TODO: Make icon about app version mismatching
	var prefab = Globals.pluginOptionPrefab
	for i in range(0, detectedPlugins.size()):
		var inst = prefab.instance()
		inst.pluginManager = self
		inst.pluginId = detectedPlugins.keys()[i]
		var plugin = detectedPlugins[inst.pluginId]
		inst.title = plugin.config.name
		if not plugin.config.appVersion == Globals.versionId:
			inst.versionMismatch = true
		if loadedPlugins.keys().has(inst.pluginId):
			inst.isActive = true
		option_container.add_child(inst)
	plugin_overlay.visible = true
	pass

func _close_plugin_menu():
	plugin_overlay.visible = false
	header_label.text = "Plugin Header"
	description_label.text = "Plugin Description"
	preview_texture.texture = null
	for i in range(option_container.get_child_count()-1, -1, -1):
		option_container.get_child(i).queue_free()
	pass

# Generates the preview of a single plugin.
func _generate_plugin_preview(id: int):
	# TODO: Make notice about app version mismatching
	var plugin = detectedPlugins[id]
	header_label.text = plugin.config.name
	var desText = ""
	if not plugin.config.appVersion == Globals.versionId:
		desText = "Warning: Plugin was made for version " + plugin.config.appVersion + ".\nIncompatibilities may occur.\n\n"
	desText += plugin.config.description
	description_label.text = desText
	if Functions.is_app() && not plugin.config.icon == "":
		preview_texture.texture = Functions.load_image(Functions.os_path_convert(plugin.path + "/" + plugin.config.icon))
	elif not Functions.is_app() && not plugin.config.icon == "":
		preview_texture.texture = Functions.load_image(plugin.path + "/" + plugin.config.icon)
	pass

func _on_CloseOverlayButton_pressed():
	_close_plugin_menu()
	pass
