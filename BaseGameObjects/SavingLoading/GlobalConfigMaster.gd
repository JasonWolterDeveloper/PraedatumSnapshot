## A Global Singleton used to keep track of the global config file which is
## used in turn to keep track of global meta variables like which character
## is currently selected, options like volume, etc.
extends Node

const GLOBAL_CONFIG_FILE_PATH = "user://global_settings.cfg"

const SELECTED_CHARACTER_KEY = "selected_character"
const MOST_RECENT_SAVE_SLOT_KEY = "most_recent_save_slot"


# ---------- PREVIOUS RAID STATUS CONSTANTS ---------- #
const PREVIOUS_RAID_STATUS_KEY = "previous_raid_status"
const PREVIOUS_RAID_SUCCESSFUL_CODE = "successful"
const PREVIOUS_RAID_FAILED_CODE = "failure"
const NO_PREVIOUS_RAID_CODE =  "no_previous_raid"

var data_dictionary = {
	SELECTED_CHARACTER_KEY : "",
	PREVIOUS_RAID_STATUS_KEY: NO_PREVIOUS_RAID_CODE
}


func _ready():
	load_settings()


func save_settings():
	save_settings_to_file(GLOBAL_CONFIG_FILE_PATH)
	

func load_settings():
	load_settings_from_file(GLOBAL_CONFIG_FILE_PATH)


func set_value_for_key(key : String, value):
	data_dictionary[key] = value
	save_settings()


func get_value_for_key(key : String):
	if data_dictionary.has(key):
		return data_dictionary[key]
	return null


func set_selected_character_name(character_name : String):
	set_value_for_key(SELECTED_CHARACTER_KEY, character_name)


func get_selected_character_name() -> String:
	return get_value_for_key(SELECTED_CHARACTER_KEY)


func set_most_recent_save_slot_name(slot_name : String):
	set_value_for_key(MOST_RECENT_SAVE_SLOT_KEY, slot_name)


func get_most_recent_save_slot_name() -> String:
	return get_value_for_key(MOST_RECENT_SAVE_SLOT_KEY)


func save_settings_to_file(filename):
	var file = FileAccess.open(filename, FileAccess.WRITE)
	var json_data = JSON.stringify(data_dictionary)
	file.store_string(json_data)
	file.close()


func load_settings_from_file(filename):
	if not FileAccess.file_exists(filename):
		DebugMaster.log_debug("Error Loading Data")
		return
	
	var file = FileAccess.open(filename, FileAccess.READ)
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	
	json.parse(json_str)
	Util.update_dictionary_from_dictionary(data_dictionary, json.data)


func was_previous_raid_successful() -> bool:
	return get_value_for_key(PREVIOUS_RAID_STATUS_KEY) == PREVIOUS_RAID_SUCCESSFUL_CODE


func set_previous_raid_successful():
	set_value_for_key(PREVIOUS_RAID_STATUS_KEY, PREVIOUS_RAID_SUCCESSFUL_CODE)


func was_previous_raid_failure() -> bool:
	return get_value_for_key(PREVIOUS_RAID_STATUS_KEY) == PREVIOUS_RAID_FAILED_CODE


func set_previous_raid_failure():
	set_value_for_key(PREVIOUS_RAID_STATUS_KEY,  PREVIOUS_RAID_FAILED_CODE)


func has_previous_raid() -> bool:
	return get_value_for_key(PREVIOUS_RAID_STATUS_KEY) != NO_PREVIOUS_RAID_CODE


func clear_previous_raid():
	set_value_for_key(PREVIOUS_RAID_STATUS_KEY, NO_PREVIOUS_RAID_CODE)
