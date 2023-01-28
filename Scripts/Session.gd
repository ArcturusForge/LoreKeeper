extends Node

var sessionName: String
var styleUsed
var data = []

var savePath := ""

func reset_data():
	savePath = ""
	sessionName = Globals.sessionNameDefault
	styleUsed = "Default." + Globals.styleExtension
	data = []

func quick_save():
	save_data(savePath)
	pass

func save_data(path: String):
	if not Globals.saveExtension in sessionName:
		sessionName += "." + Globals.saveExtension
	
	if not sessionName in path:
		path += "/" + sessionName
	
	var compilation = {
		"data" : data,
		"style" : styleUsed
	}
	print (path)
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(compilation))
	file.close()
	
	savePath = path
	pass

func load_data(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var text = file.get_as_text()
	file.close()
	
	var compilation = parse_json(text)
	styleUsed = compilation.style
	data = compilation.data
	sessionName = path.get_file()
	savePath = path
	pass
