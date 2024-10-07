class_name SaveSlotControl extends PanelContainer


# ----- Model References ----- #
var save_slot : SaveSlot

# ----- Control References ----- #
var load_button : Button
var delete_button : Button
var new_game_button : Button

var save_slot_name : Label
var save_slot_description : Label

# ----- Parent Control References ----- #
var start_new_game_control : StartNewGameControl
var load_game_control : LoadGameMenuControl

# ----- Instance Vars ----- #
var is_for_new_game : bool = false


# --------- Ready and Assignment Functions ---------- #


func _ready():
	load_button = Util.find_node_by_name(self, "LoadButton")
	delete_button = Util.find_node_by_name(self, "DeleteButton")
	new_game_button = Util.find_node_by_name(self, "NewGameButton")
	
	save_slot_name = Util.find_node_by_name(self, "SaveSlotName")
	save_slot_description = Util.find_node_by_name(self, "SaveSlotDescription")


func assign_save_slot(new_save_slot : SaveSlot):
	save_slot = new_save_slot
	update()


func assign_start_new_game_control(new_game_control : StartNewGameControl):
	start_new_game_control = new_game_control
	is_for_new_game = true


func assign_load_game_control(new_game_control : LoadGameMenuControl):
	load_game_control = new_game_control
	is_for_new_game = false



# ---------- New and Load Game Functions ---------- #


func start_new_game_for_slot():
	if start_new_game_control and save_slot:
		start_new_game_control.start_new_game_for_slot(save_slot)


func load_game_for_slot():
	if load_game_control and save_slot:
		load_game_control.load_game_for_slot(save_slot)


func delete_save_in_slot():
	if save_slot:
		if start_new_game_control:
			start_new_game_control.delete_save_slot(save_slot)
		else:
			load_game_control.delete_save_slot(save_slot)


# ----------- Update Functions ----------- #


func update():
	update_new_game_button()
	update_load_button()
	update_delete_button()
	
	update_save_slot_name()
	update_save_slot_description()


func update_new_game_button():
	if new_game_button and save_slot:
		if is_for_new_game and not save_slot.save_exists:
			new_game_button.show()
		else:
			new_game_button.hide()


func update_load_button():
	if load_button and save_slot:
		if not is_for_new_game and save_slot.save_exists:
			load_button.show()
		else:
			load_button.hide()


func update_delete_button():
	if delete_button and save_slot:
		if save_slot.save_exists:
			delete_button.show()
		else:
			delete_button.hide()


func update_save_slot_name():
	if save_slot_name and save_slot:
		save_slot_name.text = save_slot.display_name


func update_save_slot_description():
	if save_slot_name and save_slot:
		save_slot_description.text = save_slot.warrior_and_level_details


func _on_new_game_button_pressed():
	pass # Replace with function body.


func _on_load_button_pressed():
	load_game_for_slot()
	pass # Replace with function body.
