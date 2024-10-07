extends Node
## The purpose of this file is to map Interaction Icon Images to the actual
## key mapped to the particular control. This will typically be the interact key
## but we could potentially so prompts for reloading, etc, as well

const ICON_FOLDER_FILE_PATH = "res://UIObjects/Assets/InputIcons/"
const ICON_SUFFIX = "Key_Dark.png"
const ICON_STRING_CONNECTOR = "_"

const BLANK_ICON_PREFIX = "blank"
var blank_key_icon = preload("res://UIObjects/Assets/InputIcons/Blank_Key_Dark.png")

var input_string_to_icon_prefix_map = {
	"f" : "F"
}


## An actual dictionary of textures preloaded into memory during
## the ready process, mapped to input strings
var input_string_to_icon_image_map = {
	BLANK_ICON_PREFIX : blank_key_icon
}


func _ready():
	populate_input_string_to_icon_image_map()


func populate_input_string_to_icon_image_map():
	for my_input_string in input_string_to_icon_prefix_map:
		var icon_file_path = build_icon_file_path_from_input(my_input_string)
		var icon_image = load(icon_file_path)
		input_string_to_icon_image_map[my_input_string] = icon_image


func get_icon_for_input(input_string : String):
	if input_string_to_icon_image_map.has(input_string):
		return input_string_to_icon_image_map[input_string]
	# If we don't have an image mapped to the input we return an image of a blank key instead
	return blank_key_icon


func get_icon_prefix_string_from_input(input_string : String):
	if input_string_to_icon_prefix_map.has(input_string):
		return input_string_to_icon_prefix_map[input_string]
	return BLANK_ICON_PREFIX


func build_icon_string_from_input(input_string : String):
	var input_prefix = get_icon_prefix_string_from_input(input_string)
	var icon_string : String = input_prefix + ICON_STRING_CONNECTOR + ICON_SUFFIX
	return icon_string 


func build_icon_file_path_from_input(input_string : String):
	var icon_string = build_icon_string_from_input(input_string)
	var icon_file_path = ICON_FOLDER_FILE_PATH + icon_string
	return icon_file_path
