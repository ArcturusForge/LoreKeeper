extends Button

var index
var ignoreEmit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	index = get_index()
	Globals.connect(Globals.menuSelectedSignal, self, "_menu_selected")
	
	# Configure appearance.
	var styleWindowData = Globals.style[index]
	self.hint_tooltip = styleWindowData.category
	self.icon = Functions.load_image(Globals.resDataPath + Globals.iconsPath + "/" + styleWindowData.icon)
	self.icon_align = Button.ALIGN_CENTER
	self.expand_icon = true
	
	# Set default selected
	if index == 0:
		self.pressed = true

func _menu_selected(ind):
	if not ind == index:
		self.pressed = false
	elif ind == index && not self.pressed:
		ignoreEmit = true
		self.pressed = true
	

func _on_MenuBtn_toggled(button_pressed):
	if button_pressed:
		if not ignoreEmit:
			Globals.emit_signal(Globals.menuSelectedSignal, index)
		else:
			ignoreEmit = false
	elif not button_pressed && index == Globals.windowIndex:
		# So deselected current window without selecting new window
		# Reset to 0th window as precaution.
		Globals.emit_signal(Globals.menuSelectedSignal, 0)
	pass
