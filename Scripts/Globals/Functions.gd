extends Node

#--- Returns all detected files of a defined type.
func get_all_files(path: String, file_ext := "", use_full_path:= true, files := []):
	if is_app():
		path = os_path_convert(path, false)
	
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

#--- Loads and returns an image. Only works for images not built into the app.
func load_image(path:String, ignoreArgs = true):
	if is_app():
		path = os_path_convert(path, ignoreArgs)
	
	var icon = Image.new()
	icon.load(path)
	var t = ImageTexture.new()
	t.create_from_image(icon)
	return t

#--- Loads an image and returns both the image and its encoded data.
func load_image_and_encode(path:String):
	if is_app():
		path = os_path_convert(path)
	
	var imageReader = File.new()
	imageReader.open(path, File.READ)
	var encodedImage = Marshalls.raw_to_base64(imageReader.get_buffer(imageReader.get_len()))
	imageReader.close()
	
	var extension = path.get_extension()
	var texture = load_image_from_encode(extension, encodedImage)
	
	var data = [
		extension,
		encodedImage,
		texture
	]
	return data

#--- Takes an encoded image and returns the decoded image.
func load_image_from_encode(extension:String, encodedImage:String):
	var image = Image.new()
	var texture = ImageTexture.new()
	match extension.to_lower():
		"png":
			image.load_png_from_buffer(Marshalls.base64_to_raw(encodedImage))
		"jpg":
			image.load_jpg_from_buffer(Marshalls.base64_to_raw(encodedImage))
		"tga":
			image.load_tga_from_buffer(Marshalls.base64_to_raw(encodedImage))
		"bmp":
			image.load_bmp_from_buffer(Marshalls.base64_to_raw(encodedImage))
		"webp":
			image.load_webp_from_buffer(Marshalls.base64_to_raw(encodedImage))
	# Getting this back to an image was a nightmare...
	# This guy is my hero: 
	# https://github.com/godotengine/godot/issues/42346#issuecomment-699453588
	texture.create_from_image(image)
	return texture

#--- Use when creating/reading directories & files at runtime
func os_path_convert(path:String, ignoreArgs = true):
	if "user://" in path || (ignoreArgs && "res://" in path) || (not self.has_cmd_args() && "res://" in path):
		return ProjectSettings.globalize_path(path)
	elif "res://" in path:
		var dir = OS.get_executable_path().get_base_dir()
		return dir + "/" + ProjectSettings.globalize_path(path)
	return path

#--- Returns a bool for if the project is an exported app or not.
func is_app():
	return OS.has_feature("standalone")

#--- Generates a random number of a defined length.
func generate_id(length:int = 3):
	var rng = RandomNumberGenerator.new()
	var idParts = []
	for i in range(0, length):
		if i == 0:
			idParts.append(str(rng.randi_range(1,9)))
		else:
			idParts.append(str(rng.randi_range(0,9)))
	var id = ""
	for i in range(0, idParts.size()):
		id += idParts[i]
	return int(id)

#--- Creates a new instance of a tscn file.
func get_from_prefab(path: String):
	if is_app():
		return ResourceLoader.load(os_path_convert(path)).instance()
	else:
		return ResourceLoader.load(path).instance()

#--- Writes data to a json file.
func write_file(data, path:String):
	if is_app():
		path = os_path_convert(path)
	
	var f = File.new()
	f.open(path, File.WRITE)
	f.store_line(to_json(data))
	f.close()
	pass

func file_exists(path:String):
	if is_app():
		path = os_path_convert(path)
	var dir = Directory.new()
	return dir.file_exists(path)

#--- Reads a json file and returns the data.
func read_file(path:String):
	if is_app():
		path = os_path_convert(path)
	
	var f = File.new()
	if not f.file_exists(path):
		printerr("Invalid file load request: " + path)
		return null
	f.open(path, File.READ)
	var data = parse_json(f.get_as_text())
	return data

#--- Ensures that the directory path exists.
func ensure_directory(path:String):
	if is_app():
		path = os_path_convert(path)
	
	var d = Directory.new()
	if not d.dir_exists(path):
		d.make_dir_recursive(path)

func wait_frame():
	wait(0.001)
	pass

func wait(time):
	yield(get_tree().create_timer(time),"timeout")
	pass

func open_link(url):
	OS.shell_open(url)
	pass

func open_directory(path):
	OS.shell_open(str("file://", path))
	pass

#--- Checks if the app was opened by means other than the exe directly.
func has_cmd_args():
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		return true
	return false

#--- Bypasses standard procedure if a .mplan file was opened.
func open_with_cmd(target, function:String):
	var args = OS.get_cmdline_args()
	if args.size() == 1:
		funcref(target, function).call_func(args[0])
		return true
	return false

func associate_extension(associatorPath:String, args:PoolStringArray):
	associatorPath = os_path_convert(associatorPath)
	if OS.get_name() == "Windows":
		OS.execute(associatorPath, args)
	pass
