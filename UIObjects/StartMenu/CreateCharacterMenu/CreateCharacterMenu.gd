extends Control

const ALPHABET_CHARACTERS_ONLY_PATTERN = "^[a-zA-Z]+$"
const CHARACTER_NAME_EDIT_NODE_NAME = "CharacterNameEdit"
const CREATE_CHARACTER_BUTTON_NODE_NAME = "CreateCharacterButton"

var alphabet_characters_only_regex

var character_name_edit_field : LineEdit
var character_name = ""

var create_character_button : Button

var main_menu


func _ready():
	alphabet_characters_only_regex = RegEx.new()
	alphabet_characters_only_regex.compile(ALPHABET_CHARACTERS_ONLY_PATTERN)
	
	character_name_edit_field = Util.find_node_by_name(self, CHARACTER_NAME_EDIT_NODE_NAME)
	create_character_button = Util.find_node_by_name(self, CREATE_CHARACTER_BUTTON_NODE_NAME)


func assign_main_menu(new_main_menu):
	main_menu = new_main_menu


func create_character():
	if main_menu:
		SaveMaster.create_character(character_name)
		main_menu.start_game_for_character(character_name)


func check_if_string_has_only_alphabet_characters(string: String) -> bool:
	var result = alphabet_characters_only_regex.search(string)
	if is_instance_valid(result):
		return true
	return false


func check_create_character_button_validity():
	if character_name != "":
		create_character_button.disabled = false
	else:
		create_character_button.disabled = true


func _on_character_name_edit_text_changed(new_text):
	var current_carat_column = character_name_edit_field.caret_column
	
	if new_text == "" or check_if_string_has_only_alphabet_characters(new_text):
		character_name = new_text
	else:
		character_name_edit_field.text = character_name
		character_name_edit_field.caret_column = max(0, current_carat_column - 1)
		
	check_create_character_button_validity()


func _on_create_character_button_pressed():
	create_character()
