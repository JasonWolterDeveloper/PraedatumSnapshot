extends Node

## Singleton used to manage Warriors. Decides which Warrior is selected, Copies necessary data from
## the Warrior to the Player, and loads and saves Warrior information to data tome

const SELECTED_WARRIOR_SAVE_KEY = "selected_warrior_id"

var selected_warrior_id : String = "legionnaire"
var warrior_dictionary : Dictionary = {}

const content_dir = "res://Content/"
const warrior_dir = "/Code/Warriors/"
const manifest_file_name = "warrior_manifest.txt"
const file_separator = "/"

const default_level_to_required_experience := {
	1: 1000,
	2: 2000,
	3: 3000,
	4: 4000,
	5: 5000,
	6: 6000,
	7: 7000,
	8: 8000,
	9: 9000,
	10: 10000,
	11: 11000,
	12: 12000,
	13: 13000,
	14: 14000,
	15: 15000,
	16: 16000,
	17: 17000,
	18: 18000,
	19: 19000,
	20: 20000
}

const default_level_to_available_ability_points := {
	1: 2,
	2: 5,
	3: 7,
	4: 10,
	5: 11,
	6: 13,
	7: 14,
	8: 16,
	9: 17,
	10: 19,
	11: 20,
	12: 22,
	13: 23,
	14: 25,
	15: 26,
	16: 28,
	17: 29,
	18: 31,
	19: 32,
	20: 34
}

# We need a direct reference to the player's RPG mechanics master here because other entities (e.g., enemies)
# will have their own RPGMechanicsMaster instances. Thus, we can't use a global Singleton and need a specific
# reference to the player's instance.
var player_RPG_mechanics_master: RPGMechanicsMaster

var player : Player



# ---------- Generic Functions ---------- #

func _ready():
	load_warriors()


# Function to assign the player's RPG mechanics master
func assign_player_RPG_mechanics_master(rpg_master: RPGMechanicsMaster):
	player_RPG_mechanics_master = rpg_master


func assign_player(new_player : Player):
	player = new_player
	if get_selected_warrior():
		get_selected_warrior().assign_player(new_player)
		assign_player_RPG_mechanics_master(player.rpg_mechanics_master)


# Function to load warriors from manifest files. This is necessary to know which Warrior classes
# are available in the game, so if we add more later its easy to do
func load_warriors() -> void:
	var dir : DirAccess = DirAccess.open(content_dir)
	var load_path = ""

	# Open content directory
	if dir:
		# List all folders in content directory
		dir.list_dir_begin()
		var content_dir_name = dir.get_next()

		while content_dir_name != "":
			if dir.current_is_dir():
				var specific_content_folder : DirAccess = DirAccess.open(content_dir + file_separator + content_dir_name)
				
				if specific_content_folder:
					# Check if Warrior folder contains Warrior_manifest.txt
					load_path = content_dir + content_dir_name + warrior_dir + manifest_file_name
					if FileAccess.file_exists(load_path):
						var manifest_file = FileAccess.open(load_path, FileAccess.READ)
						# Read lines from manifest file and load scenes
						while !manifest_file.eof_reached():
							var scene_path = manifest_file.get_line().strip_edges()
							if scene_path != "":
								var scene_full_path = content_dir + content_dir_name + file_separator + warrior_dir + scene_path
								var scene = load(scene_full_path)
								
								if scene:
									var warrior : Warrior = scene.instantiate()
									warrior_dictionary[warrior.warrior_id] = warrior
									add_child(warrior)

						manifest_file.close()
			content_dir_name = dir.get_next()
		dir.list_dir_end()



# ---------- Warrior Selection Functions ---------- #


func swap_to_warrior(warrior_id : String):
	save_current_warrior_RPG_mechanics_to_persistent_data_tome()
	selected_warrior_id = warrior_id
	load_current_warrior_RPG_mechanics_from_persistent_data_tome()


# Getter for selected warrior
func get_selected_warrior() -> Warrior:
	if warrior_dictionary.has(selected_warrior_id):
		return warrior_dictionary[selected_warrior_id]
	return null


# Setter for selected warrior
func set_selected_warrior_id(warrior_id : String) -> void:
	selected_warrior_id = warrior_id



# ---------- Warrior Ability Functions ---------- #


func press_damage_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_damage_ability()
		if ability:
			ability.on_ability_pressed()


func press_crowd_control_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_crowd_control_ability()
		if ability:
			ability.on_ability_pressed()


func press_buff_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_buff_ability()
		if ability:
			ability.on_ability_pressed()


func press_movement_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_movement_ability()
		if ability:
			ability.on_ability_pressed()


# Function to release the selected active ability
func release_selected_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability : RPGAbility = warrior.get_selected_active_ability()
		if ability:
			ability.on_ability_released()


# Function to release the equipped damage ability
func release_damage_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_damage_ability()
		if ability:
			ability.on_ability_released()


# Function to release the equipped crowd control ability
func release_crowd_control_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_crowd_control_ability()
		if ability:
			ability.on_ability_released()


# Function to release the equipped buff ability
func release_buff_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_buff_ability()
		if ability:
			ability.on_ability_released()


# Function to release the equipped movement ability
func release_movement_ability() -> void:
	var warrior = get_selected_warrior()
	if warrior:
		var ability: RPGAbility = warrior.get_equipped_movement_ability()
		if ability:
			ability.on_ability_released()



# ---------- Update RPG_Mechanics_Master Functions ---------- #


# Sets all of the base stats for the Player to the base stats for the currently
# selected Warrior
func update_player_rpg_mechanics_from_selected_warrior():
	get_selected_warrior().copy_base_stats_to_rpg_mechanics_master(player_RPG_mechanics_master)
	get_selected_warrior().add_equipped_ability_list_to_rpg_mechanics_master(player_RPG_mechanics_master)


func add_equipped_ability_list_to_rpg_mechanics_master(other_RPG_mechanics_master : RPGMechanicsMaster):
	get_selected_warrior().add_equipped_ability_list_to_rpg_mechanics_master(player_RPG_mechanics_master)


func load_current_warrior_RPG_mechanics_from_persistent_data_tome():
	if is_instance_valid(player_RPG_mechanics_master):
		var warrior_stat_data : Dictionary = PersistentDataTome.get_data_for_key(PersistentDataTome.WARRIORS_RPG_STATS_KEY)
		
		if warrior_stat_data.has(get_selected_warrior().warrior_id):
			player_RPG_mechanics_master.load_from_dictionary(warrior_stat_data[get_selected_warrior().warrior_id])
		update_player_rpg_mechanics_from_selected_warrior()



# ---------- Saving and Loading Functions ---------- #


# Function to save currently selected warrior
func save_selected_warrior_id():
	# Assuming 'persistent_data_tone' is your custom persistent data store class or singleton
	PersistentDataTome.set_data_for_key(SELECTED_WARRIOR_SAVE_KEY, selected_warrior_id)


# Function to load selected warrior from persistent data
func load_selected_warrior_id():
	var saved_warrior_id = PersistentDataTome.get_data_for_key(SELECTED_WARRIOR_SAVE_KEY)
	
	if saved_warrior_id != null:
		selected_warrior_id = saved_warrior_id


func save_warrior_to_persistent_data_tome(warrior : Warrior):
	var warrior_data : Dictionary = PersistentDataTome.get_data_for_key(PersistentDataTome.WARRIORS_KEY)
	
	warrior_data[warrior.warrior_id] = warrior.generate_save_dictionary()


func save_current_warrior_RPG_mechanics_to_persistent_data_tome():
	if is_instance_valid(player_RPG_mechanics_master):
		var warrior_stat_data : Dictionary = PersistentDataTome.get_data_for_key(PersistentDataTome.WARRIORS_RPG_STATS_KEY)
		
		warrior_stat_data[get_selected_warrior().warrior_id] = player_RPG_mechanics_master.generate_save_dictionary()


func load_warrior_from_persistent_data_tome(warrior : Warrior):
	var warrior_data : Dictionary = PersistentDataTome.get_data_for_key(PersistentDataTome.WARRIORS_KEY)
	if warrior_data.has(warrior.warrior_id):
		warrior.load_from_save_dictionary(warrior_data[warrior.warrior_id])


func save_all_warriors():
	for my_key in warrior_dictionary.keys():
		save_warrior_to_persistent_data_tome(warrior_dictionary[my_key])


func load_all_warriors():
	for my_key in warrior_dictionary.keys():
		load_warrior_from_persistent_data_tome(warrior_dictionary[my_key])


func _process(delta: float) -> void:
	var warrior = get_selected_warrior()
	if warrior:
		warrior.ability_process(delta)
