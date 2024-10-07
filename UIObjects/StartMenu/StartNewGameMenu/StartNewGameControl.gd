class_name StartNewGameControl extends Control

const SAVE_SLOT_CONTROL_CONTAINER_NAME = "SaveSlotControlContainer"

var save_slot_control_scene = preload("res://UIObjects/StartMenu/SaveSlotControl.tscn")

var save_slot_control_container : Container
var main_menu



# ----------- Ready and Assignment Functions ---------- #


func _ready():
	save_slot_control_container = Util.find_node_by_name(self, SAVE_SLOT_CONTROL_CONTAINER_NAME)


func assign_main_menu(new_main_menu):
	main_menu = new_main_menu


func remove_and_free_buttons_from_container(container: Node):
	for child in container.get_children():
		if child is SaveSlotControl:
			container.remove_child(child)
			child.queue_free()


func populate_save_slot_controls():
	remove_and_free_buttons_from_container(save_slot_control_container)
	var save_slot_list = SaveMaster.save_slots
	
	for save_slot : SaveSlot in save_slot_list:
		var new_save_slot_control : SaveSlotControl = save_slot_control_scene.instantiate()
		save_slot_control_container.add_child(new_save_slot_control)
		new_save_slot_control.assign_start_new_game_control(self)
		new_save_slot_control.assign_save_slot(save_slot)



# ---------- Start New Game Functions ---------- #


func start_new_game_for_slot(save_slot : SaveSlot):
	if main_menu:
		SaveMaster.create_character(save_slot.save_folder_name)
		main_menu.start_game_for_character(save_slot.save_folder_name)
	
	
func delete_save_slot(save_slot : SaveSlot):
	SaveMaster.delete_save_slot(save_slot)
	SaveMaster.update_all_save_slots()
	update_all_save_slot_controls()



# ---------- UI Utilities ---------- #


func update_all_save_slot_controls():
	for child in save_slot_control_container.get_children():
		if child is SaveSlotControl:
			child.update()



func display_menu():
	SaveMaster.update_all_save_slots()
	populate_save_slot_controls()
	show()


func hide_menu():
	hide()
