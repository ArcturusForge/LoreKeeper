extends Node

var sessionName: String
var styleUsed
var data = {}

func save_data(path: String):
	var file = File.new()
	
	if not Globals.saveExtension in sessionName:
		sessionName += "." + Globals.saveExtension
	
	var compilation = {
		"data" : data,
		"style" : styleUsed
	}
	file.open(path + "/" + sessionName, File.WRITE)
	file.store_line(to_json(compilation))
	file.close()
	pass

func load_data(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	var compilation = parse_json(text)
	styleUsed = compilation.style
	data = compilation.data
	pass
