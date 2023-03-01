extends MenuButton

var popup = self.get_popup()
var options = {}
var popupData = {} 

# Options data layout:
# entityId
# > callback
# > options
# > > shortcut

# Popup data layout:
# popupId
# > option
# > entityId
# > shortcut

func _ready():
	popup.connect("id_pressed", self, "_handle_id")
	pass

func _handle_id(optionId:int):
	var data = options[popupData[optionId].entityId]
	data.callback.call_func(popupData[optionId].option)
	pass

func _generate_popup():
	popup.clear()
	popupData.clear()
	
	var popupId = 0
	for entId in options.keys():
		var ent = options[entId]
		for option in options[entId]["options"].keys():
			popupData[popupId] = {
				"option" : option,
				"entityId" : entId,
				"shortcut" : options[entId]["options"][option]
			}
			popupId += 1
	
	for popData in popupData.keys():
		var data = popupData[int(popData)]
		popup.add_item(data.option, popData)
		popup.set_item_shortcut(popup.get_item_count()-1, data.shortcut, true)
	pass

func _create_shortcut(shortcutKey, useShift:bool = false):
	var shortcut = ShortCut.new()
	var inputKey = InputEventKey.new()
	inputKey.set_scancode(shortcutKey)
	inputKey.control = true
	inputKey.shift = useShift
	shortcut.set_shortcut(inputKey)
	return shortcut

func _ifnew_entity(id:String):
	if not options.has(id):
		options[id] = {
			"callback" : null,
			"options" : {}
		}
	pass

## Above are internal funcs
# Below are public funcs

func define_entity(id:String, entity, callback:String):
	self._ifnew_entity(id)
	options[id]["callback"] = funcref(entity, callback)
	pass

func add_option(id:String, option, shortcutKey, useShift:bool = false):
	if not options.has(id):
		printerr("The id belongs to an entity that has not been defined!!")
		return
	
	options[id]["options"][option] = self._create_shortcut(shortcutKey, useShift)
	self._generate_popup()
	pass

func remove_option(id:String, option):
	if not options.has(id):
		printerr("The id belongs to an entity that has not been defined!!")
		return
	
	if options[id]["options"].has(option):
		options[id]["options"].erase(option)
		self._generate_popup()
	pass
