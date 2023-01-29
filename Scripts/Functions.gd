extends Node

# Returns files of type
func get_all_files(path: String, file_ext := "", use_full_path:= true, files := []):
	var dir = Directory.new()
	
	if OS.has_feature("standalone"):
		path = Functions.os_path_convert(path)
	
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

func load_image_and_encode(path:String):
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

func load_image_from_encode(extension:String, encodedImage:String):
	var image = Image.new()
	var texture = ImageTexture.new()
	match extension:
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

# Use when creating directories/files at runtime
func os_path_convert(path: String):
	if "res://" in path:
		return path.replace("res:/", OS.get_executable_path().get_base_dir())
	elif "user://" in path:
		return path.replace("user:/", OS.get_user_data_dir())
	return path
