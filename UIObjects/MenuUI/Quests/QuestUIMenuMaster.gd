class_name QuestUIMenuMaster extends UIMenuMaster

var quest_menu : QuestMenu 


func _ready():
	quest_menu = Util.find_node_by_name(self, "QuestMenu")


# Function to check if the menu can be opened
func can_open_menu() -> bool:
	return true


func open_menu():
	menu_open = true
	quest_menu.populate_quest_list()
	quest_menu.update()
	quest_menu.show()


func close_menu():
	menu_open = false
	quest_menu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("journal"):
		if menu_open:
			close_menu()
		else:
			open_menu()


func _on_quest_menu_visibility_changed() -> void:
	if not quest_menu.visible:
		menu_open = false
