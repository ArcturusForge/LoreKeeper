extends FileDialog

func _on_FileFinderDialog_file_selected(path):
	Globals.emit_signal(Globals.receiveFileFinder, path)
	pass # Replace with function body.

func _on_FileFinderDialog_files_selected(paths):
	Globals.emit_signal(Globals.receiveFileFinder, paths)
	pass # Replace with function body.
