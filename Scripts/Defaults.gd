extends Node

var styleDefault = [
	{
		"category": "Characters",
		"window": "Character_(collection).lkw",
		"icon": "pawn.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Factions",
		"window": "Character_(collection).lkw",
		"icon": "crown_a.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Locations",
		"window": "Character_(collection).lkw",
		"icon": "flag_square.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Items",
		"window": "Character_(collection).lkw",
		"icon": "pouch.png",
		"addIcon": "card_add.png"
	},
	{
		"category": "Concepts",
		"window": "Character_(collection).lkw",
		"icon": "puzzle.png",
		"addIcon": "card_add.png"
	}
]

var characterWindowDefault = {
  "format" : 1,
  "fields" : [
	{
	  "prompt" : "Add General Info",
	  "icon" : "notepad_write.png",
	  "header" : "General Info",
	  "asList" : true,
	  "listType" : "ElementVerticalContainer.tscn",
	  "type" : "Trait.lke",
	  "listPrompt" : "Add Trait"
	},
	{
	  "prompt" : "Add Description",
	  "icon" : "book_closed.png",
	  "header" : "Description",
	  "asList" : false,
	  "type" : "LargeText.lke"
	},
	{
	  "prompt" : "Add Gallery",
	  "icon" : "pawns.png",
	  "header" : "Gallery",
	  "asList" : true,
	  "listType" : "ElementGridContainer.tscn",
	  "type" : "Image.lke",
	  "listPrompt" : "Add Image"
	},
	{
	  "prompt" : "Add Portrait",
	  "icon" : "character.png",
	  "header" : "Portrait",
	  "asList" : false,
	  "type" : "Image.lke"
	}
  ]
}

var imageAttributeDefault = {
  "construct" : ["SpriteElement.tscn"],
  "seperatorInterval" : 0,
  "seperator" : ""
}

var traitAttributeDefault = {
  "construct" : ["TextEdit.tscn", "TextEdit.tscn"],
  "seperatorInterval" : 1,
  "seperator" : ":"
}

var lTextAttributeDefault = {
  "construct" : ["LargeTextEdit.tscn"],
  "seperatorInterval" : 0,
  "seperator" : ""
}



func generate(path:String, data):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	pass
