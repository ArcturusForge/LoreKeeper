extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect(Globals.repaintEntitiesSignal, self, "repaint")
	pass

func _on_AddEntityBtn_pressed():
	Globals.emit_signal(Globals.viewEntrySignal, self.get_index())
	pass

func repaint():
	self.text = Session.data[Globals.windowIndex][self.get_index()][0].name
