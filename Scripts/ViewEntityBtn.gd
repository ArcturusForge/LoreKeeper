extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.



func _on_AddEntityBtn_pressed():
	Globals.emit_signal(Globals.viewEntrySignal, self.get_index())
	pass # Replace with function body.