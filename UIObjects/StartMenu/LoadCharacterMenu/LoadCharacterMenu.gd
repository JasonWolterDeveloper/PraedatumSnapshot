extends Control

const LOAD_CHARACTER_BUTTON_CONTAINER_NODE_NAME = "LoadCharacterButtonContainer"

var load_character_button_scene = preload("res://UIObjects/StartMenu/LoadCharacterMenu/LoadCharacterButton.tscn")

var load_character_button_container : Container

var main_menu


func _ready():
	load_character_button_container = Util.find_node_by_name(self, LOAD_CHARACTER_BUTTON_CONTAINER_NODE_NAME)


func load_and_play_character(character_name):
	main_menu.start_game_for_character(character_name)


func assign_main_menu(new_main_menu):
	main_menu = new_main_menu


func display_load_menu():
	populate_load_character_buttons()
	show()


func remove_and_free_buttons_from_container(container: Node):
	for child in container.get_children():
		if child is Button:
			container.remove_child(child)
			child.queue_free()


func populate_load_character_buttons():
	remove_and_free_buttons_from_container(load_character_button_container)
	var character_list = SaveMaster.find_valid_character_directories()
	
	for my_character in character_list:
		var new_load_button = load_character_button_scene.instantiate()
		new_load_button.setup_from_character(my_character)
		new_load_button.assign_load_character_menu(self)
		load_character_button_container.add_child(new_load_button)
