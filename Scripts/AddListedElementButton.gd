extends Button

var nodeIndex
var listParent
var listElementIndex


func _on_AddListedElementBtn_pressed():
	Globals.emit_signal(Globals.addElementSignal, nodeIndex, listParent, listElementIndex)
	self.queue_free()
	pass
