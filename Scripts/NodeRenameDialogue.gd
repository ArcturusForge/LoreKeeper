extends ConfirmationDialog

var currentIndex

func _on_LineEdit_text_entered(_new_text):
	self.emit_signal("confirmed")
	self.hide()
	pass
