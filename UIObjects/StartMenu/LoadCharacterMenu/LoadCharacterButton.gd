extends Button

var character_name = ""
var load_character_menu


func assign_load_character_menu(new_menu):
	load_character_menu = new_menu


func setup_from_character(new_character_name : String):
	character_name = new_character_name
	text = new_character_name


func _on_pressed():
	load_character_menu.load_and_play_character(character_name)
