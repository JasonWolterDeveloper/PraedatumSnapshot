class_name SaveSlot extends Resource

const EMPTY_STRING = "EMPTY"
const LEVEL_STRING = " LEVEL "


@export var display_name = "Save Slot 1"
@export var save_folder_name = "save_slot_1"

var warrior_and_level_details : String = ""
var save_exists : bool = false


func update():
	update_save_exists()
	update_warrior_and_level_details()


func update_save_exists():
	var persistent_data_tome = get_persistent_data_tome_file_path()
	save_exists = FileAccess.file_exists(persistent_data_tome)


func update_warrior_and_level_details():
	if save_exists:
		warrior_and_level_details = " - Exists"
	else:
		warrior_and_level_details = " - " + EMPTY_STRING



# ---------- Getters and Setters ---------- #

func get_save_directory():
	return SaveMaster.get_directory_path_for_save_folder(save_folder_name)


func get_persistent_data_tome_file_path():
	return SaveMaster.os_path_join_strings(get_save_directory(), SaveMaster.PERSISTENT_DATA_TOME_FILE_NAME)
