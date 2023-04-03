extends Control

#-- Constants
const my_id = "search"

#-- Scene Refs
onready var file_dialog = $"../../SessionFileDialog"

func jump_start():
	Globals.set_manager(my_id, self)
	pass

func set_default_path(path:String):
	file_dialog.current_dir = path
	pass

func search_for_session(target, method:String):
	reset_connections()
	file_dialog.connect("file_selected", target, method)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.lore"]
	file_dialog.dialog_text = "Select a .mplan session to load..."
	file_dialog.window_title = "Load a Session"
	file_dialog.popup()
	pass

func search_to_save(target, method:String):
	reset_connections()
	file_dialog.connect("file_selected", target, method)
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.filters = ["*.lore"]
	file_dialog.dialog_text = "Select a location to save your session..."
	file_dialog.window_title = "Save Session"
	file_dialog.popup()
	pass

func search_custom(filterArray:Array, access:int, mode:int, dialogue:String, title:String, event:String, target:Node, method:String):
	reset_connections(event)
	file_dialog.connect(event, target, method)
	file_dialog.filters = filterArray
	file_dialog.access = access
	file_dialog.mode = mode
	file_dialog.dialog_text = dialogue
	file_dialog.window_title = title
	file_dialog.popup()
	pass

func reset_connections(event:String = "file_selected"):
	var connected = file_dialog.get_signal_connection_list(event)
	for conn in connected:
		file_dialog.disconnect(conn.signal, conn.target, conn.method)
	pass
