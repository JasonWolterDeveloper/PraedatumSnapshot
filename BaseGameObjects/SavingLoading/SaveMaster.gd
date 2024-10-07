extends Node

var level

const SAVES_FOLDER = "user://saves"
const DATA_FOLDER = "res://Data"
const DEFAULT_CHARACTER_DIRECTORY = "default"

const DEFAULT_STASH_FILE_NAME = "starter_player_stash.json"

const PLAYER_INVENTORY_SAVE_FILE_NAME = "player_inventory.json"
const PLAYER_STASH_SAVE_FILE_NAME = "player_stash.json"
const PLAYER_RPG_MECHANICS_SAVE_FILE_NAME = "player_rpg_mechanics.json"

const PERSISTENT_DATA_TOME_FILE_NAME = "persistent_data_tome.json"


# ----- Save Slot Variables ----- #

@export var save_slots : Array[SaveSlot] = []


func _ready():
	# Making Saves Folder
	DirAccess.make_dir_absolute(SAVES_FOLDER)


func update_all_save_slots():
	for save_slot : SaveSlot in save_slots:
		save_slot.update()


func assign_level(new_level):
	level = new_level
	

func save_player_inventory():
	if get_level().get_player_inventory() != null:
		save_inventory_to_file(get_level().get_player_inventory(), get_inventory_file_path_for_selected_character())


func save_player_stash():
	if get_level().stash_storage != null:
		save_storage_to_file(get_level().stash_storage, get_stash_file_path_for_selected_character())


func save_player_rpg_mechanics():
	if get_level().get_player() != null:
		save_rpg_mechanics_to_file(get_level().get_player().rpg_mechanics_master, get_rpg_mechanics_file_path_for_selected_characters())


func save_player_persistent_data_tome():
	# NOTE this MUST be done before saving the data tome
	HomeBaseFacilityMaster.save_base_facilities_to_persistent_data_tome()
	QuestSystemMaster.save_to_persistent_data_tome()
	WarriorMaster.save_all_warriors()
	WarriorMaster.save_current_warrior_RPG_mechanics_to_persistent_data_tome()
	save_persistent_data_tome_to_file(get_persistent_data_tome_file_path_for_selected_character())


func load_player_inventory():
	if FileAccess.file_exists(get_inventory_file_path_for_selected_character()):
		if get_level().get_player_inventory() != null:
			load_inventory_from_file(get_level().get_player_inventory(), get_inventory_file_path_for_selected_character())


func load_player_stash():
	if FileAccess.file_exists(get_stash_file_path_for_selected_character()):
		if get_level().stash_storage != null:
			load_storage_from_file(get_level().stash_storage, get_stash_file_path_for_selected_character())


func load_player_rpg_mechanics():
	if FileAccess.file_exists(get_rpg_mechanics_file_path_for_selected_characters()):
		if get_level().get_player_inventory() != null:
			load_rpg_mechanics_from_file(get_level().get_player().rpg_mechanics_master, get_rpg_mechanics_file_path_for_selected_characters())


func load_player_persistent_data_tome():
	if FileAccess.file_exists(get_persistent_data_tome_file_path_for_selected_character()):
		load_persistent_data_tome_from_file(get_persistent_data_tome_file_path_for_selected_character())
		QuestSystemMaster.load_from_persistent_data_tome()
		WarriorMaster.load_all_warriors()
		WarriorMaster.load_current_warrior_RPG_mechanics_from_persistent_data_tome()


func delete_save_slot(save_slot : SaveSlot):
	var save_slot_name : String = save_slot.save_folder_name
	var directory = DirAccess.open(get_directory_path_for_character(save_slot_name))
	directory.remove(PLAYER_STASH_SAVE_FILE_NAME)
	directory.remove(PLAYER_INVENTORY_SAVE_FILE_NAME)
	directory.remove(PLAYER_RPG_MECHANICS_SAVE_FILE_NAME)
	directory.remove(PERSISTENT_DATA_TOME_FILE_NAME)
	

func save_all_current_character_data():
	make_directory_for_selected_character()
	save_player_inventory()
	save_player_stash()
	save_player_rpg_mechanics()
	save_player_persistent_data_tome()


func load_all_current_character_data():
	make_directory_for_selected_character()


func save_rpg_mechanics_to_file(my_rpg_mechancs: RPGMechanicsMaster, file_path):
	make_directory_for_selected_character()
	var rpg_mechanics_storage_file = FileAccess.open(file_path, FileAccess.WRITE)
	var rpg_mechanics_save_string = JSON.stringify(my_rpg_mechancs.generate_save_dictionary(), "\t")
	rpg_mechanics_storage_file.store_line(rpg_mechanics_save_string)
	rpg_mechanics_storage_file.close()


func save_inventory_to_file(my_inventory : Inventory, file_path):
	make_directory_for_selected_character()
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.WRITE)
	var inventory_save_string = JSON.stringify(my_inventory.generate_save_dictionary(), "\t")
	inventory_storage_file.store_line(inventory_save_string)
	inventory_storage_file.close()


func save_storage_to_file(my_storage : Storage, file_path):
	make_directory_for_selected_character()
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.WRITE)
	var storage_save_string = JSON.stringify(my_storage.generate_save_dictionary(), "\t")
	inventory_storage_file.store_line(storage_save_string)
	inventory_storage_file.close()


func save_persistent_data_tome_to_file(filename):
	make_directory_for_selected_character()
	var file = FileAccess.open(filename, FileAccess.WRITE)
	var json_data = JSON.stringify(PersistentDataTome.tome_of_data, "\t")
	file.store_string(json_data)
	file.close()


func load_rpg_mechanics_from_file(my_rpg_mechancs : RPGMechanicsMaster, file_path):
	"""""
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.READ)
	var storage_load_lines = inventory_storage_file.get_line()
	DebugMaster.log_debug("This is the line: " + storage_load_lines, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var my_storage_dictionary = Dictionary(storage_load_lines)
	"""
	
	var f = FileAccess.open(file_path, FileAccess.READ)
	var json_object = JSON.new()
	var file_text = f.get_as_text()
	DebugMaster.log_debug("This is the text: " + file_text, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var parse_err = json_object.parse(file_text)
	DebugMaster.log_debug("This is the error: " + str(json_object.get_error_message()), DebugMaster.INVENTORY_DEBUG_CATEGORY)
	my_rpg_mechancs.load_from_dictionary(json_object.get_data())


func load_storage_from_file(my_storage : Storage, file_path):
	"""""
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.READ)
	var storage_load_lines = inventory_storage_file.get_line()
	DebugMaster.log_debug("This is the line: " + storage_load_lines, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var my_storage_dictionary = Dictionary(storage_load_lines)
	"""
	
	var f = FileAccess.open(file_path, FileAccess.READ)
	var json_object = JSON.new()
	var file_text = f.get_as_text()
	DebugMaster.log_debug("This is the text: " + file_text, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var parse_err = json_object.parse(file_text)
	DebugMaster.log_debug("This is the error: " + str(json_object.get_error_message()), DebugMaster.INVENTORY_DEBUG_CATEGORY)
	my_storage.load_from_dictionary(json_object.get_data())


func load_inventory_from_file(my_inventory : Inventory, file_path):
	"""""
	var inventory_storage_file = FileAccess.open(file_path, FileAccess.READ)
	var storage_load_lines = inventory_storage_file.get_line()
	DebugMaster.log_debug("This is the line: " + storage_load_lines, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var my_storage_dictionary = Dictionary(storage_load_lines)
	"""
	
	var f = FileAccess.open(file_path, FileAccess.READ)
	var json_object = JSON.new()
	var file_text = f.get_as_text()
	DebugMaster.log_debug("This is the text: " + file_text, DebugMaster.INVENTORY_DEBUG_CATEGORY)
	var parse_err = json_object.parse(file_text)
	DebugMaster.log_debug("This is the error: " + str(json_object.get_error_message()), DebugMaster.INVENTORY_DEBUG_CATEGORY)
	my_inventory.load_from_dictionary(json_object.get_data())


func load_persistent_data_tome_from_file(filename):
	if not FileAccess.file_exists(filename):
		DebugMaster.log_debug("Error Loading Data")
		return
	
	var file = FileAccess.open(filename, FileAccess.READ)
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	
	json.parse(json_str)
	
	# Note that we update from dictionary here rather than replacing as we don't want to delete any
	# default keys
	Util.update_dictionary_from_dictionary(PersistentDataTome.tome_of_data, json.data)


func create_character(character_name : String):
	DirAccess.make_dir_absolute(get_directory_path_for_character(character_name))
	copy_default_stash_to_character(character_name)


func copy_default_stash_to_character(character_name : String):
	var default_stash_file_name = os_path_join_strings(DATA_FOLDER, DEFAULT_STASH_FILE_NAME)
	copy_file_to_new_path(default_stash_file_name, get_stash_file_path_for_character(character_name))


func make_directory_for_selected_character():
	DirAccess.make_dir_absolute(get_directory_path_for_selected_character())


func get_rpg_mechanics_file_path_for_selected_characters():
	return os_path_join_strings(get_directory_path_for_selected_character(), PLAYER_RPG_MECHANICS_SAVE_FILE_NAME)


func get_stash_file_path_for_selected_character():
	return os_path_join_strings(get_directory_path_for_selected_character(), PLAYER_STASH_SAVE_FILE_NAME)


func get_stash_file_path_for_character(character_name : String):
	return os_path_join_strings(get_directory_path_for_character(character_name), PLAYER_STASH_SAVE_FILE_NAME)
	
	
func get_inventory_file_path_for_character(character_name : String):
	return os_path_join_strings(get_directory_path_for_character(character_name), PLAYER_INVENTORY_SAVE_FILE_NAME)


func get_rpg_mechanics_file_path_for_save_slot_name(save_slot_name : String):
	return os_path_join_strings(get_directory_path_for_character(save_slot_name), PLAYER_RPG_MECHANICS_SAVE_FILE_NAME)


func get_persistent_data_tome_file_path_for_character(character_name : String):
	return os_path_join_strings(get_directory_path_for_character(character_name), PERSISTENT_DATA_TOME_FILE_NAME)


func get_inventory_file_path_for_selected_character():
	return os_path_join_strings(get_directory_path_for_selected_character(), PLAYER_INVENTORY_SAVE_FILE_NAME)


func get_persistent_data_tome_file_path_for_selected_character():
	return os_path_join_strings(get_directory_path_for_selected_character(), PERSISTENT_DATA_TOME_FILE_NAME)


func find_valid_character_directories() -> Array:
	var valid_directories = []

	var dir = DirAccess.open(SAVES_FOLDER)
	
	dir.list_dir_begin()

	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		
		var file_path = os_path_join_strings(SAVES_FOLDER, file_name)
		
		if dir.current_is_dir():
			if check_directory_is_valid_character(file_path):
				valid_directories.append(file_name)
	
	dir.list_dir_end()

	return valid_directories


func check_directory_is_valid_character(dir_path : String):
	# TODO - Make this actually work
	return true


func get_directory_path_for_selected_character():
	var selected_character_name = GlobalConfigMaster.get_selected_character_name()
	if selected_character_name == null:
		selected_character_name = DEFAULT_CHARACTER_DIRECTORY
		
	return get_directory_path_for_character(selected_character_name)


func get_directory_path_for_save_folder(save_folder_name : String):
	return os_path_join_strings(SAVES_FOLDER, save_folder_name)


func get_directory_path_for_character(character_name : String):
	return os_path_join_strings(SAVES_FOLDER, character_name)


func os_path_join_strings(string1 : String, string2 : String):
	return string1 + "/" + string2


func copy_file_to_new_path(orig_file_path : String, new_file_path : String):
	var old_file = FileAccess.open(orig_file_path, FileAccess.READ)
	var content = old_file.get_as_text()
	
	var new_file = FileAccess.open(new_file_path, FileAccess.WRITE)
	new_file.store_string(content)


func get_level():
	return level
