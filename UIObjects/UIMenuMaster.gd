class_name UIMenuMaster extends Node

var player : Player = null
var level : Level
var menu_open = false

# Used to stop our menus from accepting input. This is currently only used for
# the Avalon Menu to prevent other menus from popping up while its open
var accepting_input = true

var universal_menu_master : UniversalMenuMaster:
	get: return get_parent()


func is_menu_open() -> bool:
	return menu_open


func assign_player(new_player):
	player = new_player
	

func has_player():
	return player != null


func assign_level(new_level):
	level = new_level


func set_accepting_input(value : bool):
	accepting_input = value


# Function to check if the menu can be opened
func can_open_menu() -> bool:
	if universal_menu_master != null:
		return not universal_menu_master.are_menus_open()
	else:
		return true
