class_name GameOverMenuMaster extends UIMenuMaster

@onready var game_over_menu = $GameOverMenu


# Function to check if the menu can be opened
func can_open_menu() -> bool:
	return true


func open_menu():
	menu_open = true
	game_over_menu.show()


func assign_player(new_player : Player):
	super(new_player)
	player.died.connect(on_player_death)


func on_player_death():
	open_menu()


func _on_return_to_hub_button_pressed():
	DebugMaster.log_debug("Here's the level: " + str(level))
	if level != null:
		level.handle_player_death()
