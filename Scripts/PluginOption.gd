extends HBoxContainer

onready var activate_check_box = $ActivateCheckBox
onready var preview_button = $PreviewButton
onready var alert_overlay = $PreviewButton/AlertOverlay

var pluginManager
var versionMismatch = false
var pluginId = 999
var isActive = false
var title

func _ready():
	preview_button.text = title
	if versionMismatch:
		alert_overlay.visible = true
	if isActive:
		activate_check_box.pressed = true
	pass


func _on_ActivateCheckBox_toggled(state):
	if state && not isActive:
		isActive = true
		pluginManager._load_plugin(pluginId)
	elif not state && isActive:
		isActive = false
		pluginManager._unload_plugin(pluginId)
	pass

func _on_PreviewButton_pressed():
	pluginManager._generate_plugin_preview(pluginId)
	pass
