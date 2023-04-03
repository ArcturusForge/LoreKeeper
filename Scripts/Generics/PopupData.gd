extends Node

var popup
var entries = {}
var generatedData = {}

# Options data layout:
# entityId
# > callback
# > options
# > > text
# > > shortcut
# > > isSeparator
# > > isLocked

# Popup data layout:
# popupId
# > option
# > entityId
# > shortcut
# > isSeparator
# > isLocked

func construct(popupRef):
	self.popup = popupRef
	self.popup.connect("id_pressed", self, "_handle_id")
	pass

func _handle_id(optionId:int):
	var data = entries[generatedData[optionId].entityId]
	data.callback.call_func(generatedData[optionId].option)
	pass

func _generate_popup():
	popup.clear()
	generatedData.clear()
	
	var popupId = 0
	for entId in entries.keys():
		var ent = entries[entId]
		for i in range(0, ent.options.size()):
			var option = ent.options[i]
			generatedData[popupId] = {
				"option" : option.text,
				"entityId" : entId,
				"shortcut" : option.shortcut,
				"isSeparator" : option.isSeparator,
				"isLocked" : option.isLocked
			}
			popupId += 1
	
	for popData in generatedData.keys():
		var data = generatedData[int(popData)]
		if data.isSeparator == false:
			popup.add_item(data.option, popData)
			popup.set_item_disabled(popup.get_item_count()-1, data.isLocked)
			if not data.shortcut == null:
				popup.set_item_shortcut(popup.get_item_count()-1, data.shortcut, true)
		elif data.isSeparator == true:
			popup.add_separator(data.option)
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
	if not entries.has(id):
		entries[id] = {
			"callback" : null,
			"options" : []
		}
	pass

##--- Above are internal funcs
#--- Below are public funcs

#--- Adds a new entity to the popup.
func register_entity(id:String, entity, callback:String):
	self._ifnew_entity(id)
	entries[id].callback = funcref(entity, callback)
	pass

#--- Removes a listed entity and all of its data from the popup.
func unregister_entity(id:String):
	if not entries.has(id):
		return
	
	entries.erase(id)
	self._generate_popup()
	pass

#--- Adds an option to a specific entry.
func add_option(id:String, option:String, shortcutKey = null, useShift:bool = false, locked:bool = false):
	if not entries.has(id):
		printerr("The id belongs to an entity that has not been defined!!")
		return
	
	var data = {
		"text" : option,
		"shortcut" : null,
		"isSeparator" : false,
		"isLocked":locked
	}
	
	if not shortcutKey == null:
		data.shortcut = self._create_shortcut(shortcutKey, useShift)
	
	entries[id].options.append(data)
	self._generate_popup()
	pass

#--- Removes the last matching option listed under a specific entry.
func remove_option(id:String, option):
	if not entries.has(id):
		printerr("The id belongs to an entity that has not been defined!!")
		return
	
	for i in range (entries[id].options.size()-1,-1,-1) :
		var entry = entries[id].options[i]
		if entry.text == option:
			entries[id].options.remove(i)
			self._generate_popup()
			return
	pass

#--- Adds a separator to a specific entry.
func add_separator(id:String, text:String = ""):
	if not entries.has(id):
		printerr("The id belongs to an entity that has not been defined!!")
		return
	
	var data = {
		"text" : text,
		"shortcut" : null,
		"isSeparator" : true,
		"isLocked":false
	}
	entries[id].options.append(data)
	self._generate_popup()
	pass

#--- Removes the last added matching separator listed under a specific entry.
func remove_separator(id:String, text:String = ""):
	if not entries.has(id):
		return
	
	for i in range (entries[id].options.size()-1,-1,-1) :
		var entry = entries[id].options[i]
		if entry.text == text && entry.isSeparator:
			entries[id].options.remove(i)
			self._generate_popup()
			return
	pass

#--- Removes all separators listed under a specific entry.
func remove_all_separators(id:String):
	if not entries.has(id):
		return
	
	for i in range (entries[id].options.size()-1,-1,-1) :
		var entry = entries[id].options[i]
		if entry.isSeparator:
			entries[id].options.remove(i)
			self._generate_popup()
	pass

#--- Locks an option for the user.
func lock_option(id:String, text:String):
	if not entries.has(id):
		return
	
	for i in range (entries[id].options.size()-1,-1,-1) :
		var entry = entries[id].options[i]
		if entry.text == text:
			entry.isLocked = true
			self._generate_popup()
			return
	pass

#--- Unlocks an option for the user.
func unlock_option(id:String, text:String):
	if not entries.has(id):
		return
	
	for i in range (entries[id].options.size()-1,-1,-1) :
		var entry = entries[id].options[i]
		if entry.text == text:
			entry.isLocked = false
			self._generate_popup()
			return
	pass
