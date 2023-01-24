extends Node

# Returns files of type
func get_all_files(path: String, file_ext := "", use_full_path:= true, files := []):
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, use_full_path, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

				if not use_full_path:
					files.append(file_name)
				else:
					files.append(dir.get_current_dir().plus_file(file_name))

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files

func load_image(path:String):
	var icon = Image.new()
	icon.load(path)
	var t = ImageTexture.new()
	t.create_from_image(icon)
	return t
