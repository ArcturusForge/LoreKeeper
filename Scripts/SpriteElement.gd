extends Button

onready var texture_rect = $TextureRect

var elementIndex #TODO: Will be assigned by freeform node to enable listed elements.

func _ready():
	var parentIndex = self.get_parent().index
	var entityData = Session.get_current_entity()
	if entityData[parentIndex].data.size() > self.get_index():
		var encodeData = entityData[parentIndex].data[self.get_index()]
		#var encodeData = entityData[parentIndex].data[elementIndex][self.get_index()]
		texture_rect.texture = Functions.load_image_from_encode(encodeData[0], encodeData[1])
	pass

func _on_SpriteElement_pressed():
	var filters = [
		"*.png",
		"*.jpg",
		"*.tga",
		"*.bmp",
		"*.webp"
	]
	var access = 2
	var mode = 0
	Globals.emit_signal(Globals.requestFileFinder, filters, access, mode, "Select an image file.", "Select Image")
	Globals.connect(Globals.receiveFileFinder, self, "get_image")
	pass

func get_image(path: String):
	Globals.disconnect(Globals.receiveFileFinder, self, "get_image")
	var imageData = Functions.load_image_and_encode(path)
	texture_rect.texture = imageData[2]
	
	var parentIndex = self.get_parent().index
	var entityData = Session.get_current_entity()
	
	if entityData[parentIndex].data.size() <= self.get_index():
		entityData[parentIndex].data.append([imageData[0], imageData[1]])
	else:
		entityData[parentIndex].data[self.get_index()] = [imageData[0], imageData[1]]
	pass
