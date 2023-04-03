extends ScrollContainer

var sHBar: HScrollBar
var sVBar: VScrollBar

export var trackToMaxH: bool
export var trackToMaxV: bool

var maxH : int = 0
var maxV : int = 0

func _ready():
	if self.scroll_horizontal_enabled:
		sHBar = self.get_h_scrollbar()
		sHBar.connect("changed", self, "handle_h_bar")
		maxH = sHBar.max_value
	
	if self.scroll_vertical_enabled:
		sVBar = self.get_v_scrollbar()
		sVBar.connect("changed", self, "handle_v_bar")
		maxV = sVBar.max_value
	pass

func handle_h_bar():
	if maxH != sHBar.max_value:
		maxH = sHBar.max_value
		self.scroll_horizontal = maxH
	pass

func handle_v_bar():
	if maxV != sVBar.max_value:
		maxV = sVBar.max_value
		self.scroll_vertical = maxV
	pass
