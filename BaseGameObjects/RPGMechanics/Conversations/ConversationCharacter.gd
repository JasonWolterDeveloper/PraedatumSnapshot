class_name ConversationCharacter extends Resource

const DEFAULT_PORTRAIT_KEY = "default"
var backup_portrait : Texture = preload("res://UIObjects/Assets/ConversationUI/DefaultPortrait.png")

@export var unique_id : String = ""
@export var display_name : String = ""
@export var display_name_colour : Color = Color.WHITE
@export var portraits : Dictionary = {}


func get_portrait_for_key(key : String):
	if portraits.has(key):
		return portraits[key]
	else:
		if portraits.has(DEFAULT_PORTRAIT_KEY):
			return portraits[DEFAULT_PORTRAIT_KEY]
		else:
			return backup_portrait
			
