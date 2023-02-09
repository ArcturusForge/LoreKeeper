extends Button

var nodeIndex
var listParent
var listElementIndex

func _ready():
	Globals.connect(Globals.removeElementSignal, self, "element_removed")

func element_removed(nIndex):
	if self.nodeIndex == nIndex:
		listElementIndex -= 1
		print (str(listElementIndex))

func _on_AddListedElementBtn_pressed():
	Globals.emit_signal(Globals.addElementSignal, nodeIndex, listParent, listElementIndex)
	Globals.disconnect(Globals.removeElementSignal, self, "element_removed")
	self.queue_free()
	pass
