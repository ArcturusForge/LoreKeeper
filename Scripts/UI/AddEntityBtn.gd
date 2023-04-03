extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup button icon
	var styleWindowData = Globals.style[Globals.windowIndex]
	self.hint_tooltip = "Add new entry"
	self.icon = Functions.load_image(Globals.resDataPath + Globals.iconsPath + "/" + styleWindowData.addIcon)
	self.icon_align = Button.ALIGN_CENTER
	self.expand_icon = true
	pass # Replace with function body.

func _on_AddEntityBtn_pressed():
	Globals.emit_signal(Globals.createEntrySignal, Globals.windowIndex, self.get_index())
	pass # Replace with function body.
