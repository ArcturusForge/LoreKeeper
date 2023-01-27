extends VBoxContainer

onready var nameInput = $NameContainer/EntityName

func _ready():
	Globals.connect(Globals.createEntityElementSignal, self, "generate_element")
	var entityData = Session.data[Globals.windowIndex][Globals.entityIndex]
	if not entityData[0].name == "Rename":
		nameInput.text = entityData[0].name
	pass

func generate_element(elementIndex: int):
	#TODO:
	print("Creating an element of index: " + String(elementIndex))
	pass


func _on_EntityName_text_entered(new_text):
	var entityData = Session.data[Globals.windowIndex][Globals.entityIndex]
	entityData[0].name = new_text
	Globals.emit_signal(Globals.repaintEntitiesSignal)
	pass # Replace with function body.
