## Warrior class script for role-playing game mechanics. Works like Character Classes in other Games
## Handles attributes like current level, experience points, and selected abilities for the class 
## build.

class_name Warrior extends Node

# Constants for save keys
const CURRENT_LEVEL_KEY = "current_level"
const CURRENT_EXPERIENCE_POINTS_KEY = "current_experience_points"
const EQUIPPED_ABILITY_IDS_KEY = "equipped_abilities"

@export var warrior_id : String = ""
@export var display_name : String = ""

# Define properties
var current_level : int = 1
var current_experience_points : int = 0

var ability_list : Array[RPGAbility] = []
var equipped_ability_list : Array[RPGAbility] = []
var equipped_active_ability_list : Array[RPGAbility] = []

# List of active abilities
var active_ability_list : Array[RPGAbility] = []

# Index of the selected active ability
var selected_active_ability_index : int = 0

var equipped_damage_ability: DamageAbility
var equipped_crowd_control_ability: CrowdControlAbility
var equipped_buff_ability: BuffAbility
var equipped_movement_ability: MovementAbility

## base_ability_points is the number of ability points the class has at level 0
@export var base_ability_points : int = 0
var used_ability_points : int = 0

## rpg_mechanics_master is an rpg mechanics master that is designed to store
## base stat values for each warrior. For example, legionnaires have 2 health pips and
## the paladin has 3 in base stats and that needs to be reflected
@export var rpg_mechanics_master : RPGMechanicsMaster

var player : Player

signal experience_points_changed



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	populate_ability_list()


# Function to recursively process children
func populate_ability_list(node=self):
	for child in node.get_children():
		# Check if the child is of type RPGAbility
		if child is RPGAbility:
			ability_list.append(child)
			child.assign_warrior(self)
			
			if child.is_active:
				add_active_ability(child)
			
			# Add equipped children to the equipped list. Note that this is for debug purposes only
			if child.equipped:
				equip_ability(child)
			
		# Recursively process the child's children
		populate_ability_list(child)


## assign_equipped_active_abilities searchs are equipped ability list for active
## abilities of the four different types and assigns them to the appropriate variable
## as necessary
func assign_equipped_active_abilities():
	equipped_damage_ability = null
	equipped_crowd_control_ability = null
	equipped_movement_ability = null
	equipped_buff_ability = null

	for ability : RPGAbility in equipped_ability_list:
		if ability is DamageAbility:
			equipped_damage_ability = ability
		elif ability is CrowdControlAbility:
			equipped_crowd_control_ability = ability
		elif ability is BuffAbility:
			equipped_buff_ability = ability
		elif ability is MovementAbility:
			equipped_movement_ability = ability


func assign_player(new_player : Player):
	player = new_player
	for ability : RPGAbility in ability_list:
		ability.assign_player(player)


## copy_base_stats_to_rpg_mechanics_master() grabs all of the base stats from our rpg mechanics
## master and copies them to another. Intended to be used when this Warrior is the selected Warrior
## to set the Player Object's Base Stats to that of the warrior
func copy_base_stats_to_rpg_mechanics_master(other_RPG_mechanics_master : RPGMechanicsMaster):
	rpg_mechanics_master.copy_base_stats_to_RPG_mechanics_master(other_RPG_mechanics_master)


func add_equipped_ability_list_to_rpg_mechanics_master(other_RPG_mechanics_master : RPGMechanicsMaster):
	other_RPG_mechanics_master.add_rpg_ability_list(equipped_ability_list)



# ---------- RPG Ability Info ---------- #


func equip_ability(rpg_ability : RPGAbility) -> void:
	if not rpg_ability in equipped_ability_list:
		rpg_ability.equipped = true
		Util.append_array_unique(equipped_ability_list, rpg_ability)
		if rpg_ability.is_active:
			Util.append_array_unique(equipped_active_ability_list, rpg_ability)
		recalculate_used_ability_points()
		
		if GameMaster.get_player() and WarriorMaster.get_selected_warrior() == self:
			add_equipped_ability_list_to_rpg_mechanics_master(GameMaster.get_player().rpg_mechanics_master)
			DebugMaster.log_debug("We've added the ability")


func unequip_ability(rpg_ability : RPGAbility) -> void:
	rpg_ability.equipped = false
	Util.delete_object_from_array(equipped_ability_list, rpg_ability)
	if rpg_ability.is_active:
		Util.delete_object_from_array(equipped_active_ability_list, rpg_ability)
	recalculate_used_ability_points()
	
	if GameMaster.get_player() and WarriorMaster.get_selected_warrior() == self:
		add_equipped_ability_list_to_rpg_mechanics_master(GameMaster.get_player().rpg_mechanics_master)
		DebugMaster.log_debug("We've added the ability")


func equip_abilities_from_id_list(ability_id_list : Array) -> void:
	for id : String in ability_id_list:
		for ability : RPGAbility in ability_list:
			if id == ability.ability_id:
				equip_ability(ability)
				break
	
	# Update our equipped active abilities
	assign_equipped_active_abilities()


func generate_equipped_id_list() -> Array[String]:
	var id_list : Array[String] = []
	for ability in equipped_ability_list:
		id_list.append(ability.ability_id)
	return id_list


func recalculate_used_ability_points() -> void:
	used_ability_points = 0
	for my_ability : RPGAbility in equipped_ability_list:
		used_ability_points += my_ability.ability_point_cost


func get_available_ability_points():
	return get_total_ability_points() - used_ability_points


func get_total_ability_points() -> int:
	var total_ability_points : int = base_ability_points
	if WarriorMaster.default_level_to_available_ability_points.has(current_level):
		total_ability_points += WarriorMaster.default_level_to_available_ability_points[current_level]
	return total_ability_points


func ability_process(delta : float):
	for ability : RPGAbility in ability_list:
		ability.ability_process(delta)



# ---------- Active Abilities ---------- #


# Function to cycle the selected active ability
func cycle_selected_active_ability():
	var previous_ability : RPGAbility = get_selected_active_ability()
	
	selected_active_ability_index += 1
	if selected_active_ability_index >= equipped_active_ability_list.size():
		selected_active_ability_index = 0
	
	var new_ability : RPGAbility = get_selected_active_ability()
	
	if previous_ability != new_ability:
		previous_ability.on_deselected()
		new_ability.on_selected()


func get_selected_active_ability():
	if equipped_active_ability_list.size() > 0:
		return equipped_active_ability_list[selected_active_ability_index]
	else:
		return null


func add_active_ability(ability : RPGAbility):
	active_ability_list.append(ability)



# ---------- Experience and Leveling ---------- #


func debug_add_experience():
	gain_experience(600)
	DebugMaster.log_debug("This is our current experience: " + str(current_experience_points))


func get_experience_to_level_mapping():
	return WarriorMaster.default_level_to_required_experience


func get_experience_to_next_level():
	var next_level = current_level + 1
	var experience_to_level_mapping : Dictionary = get_experience_to_level_mapping()
	if experience_to_level_mapping.has(next_level):
		return experience_to_level_mapping[next_level]
	return -1


func calculate_progress_to_next_level_as_percentage():
	return float(current_experience_points)/float(get_experience_to_next_level()) * 100.0

	
func level_up_if_possible():
	var experience_to_next_level = get_experience_to_next_level()
	if experience_to_next_level != -1 and current_experience_points >= experience_to_next_level:
		level_up()

	
func level_up():
	current_experience_points -= get_experience_to_next_level()
	current_level += 1
	
	DebugMaster.log_debug("This is our current level: " + str(current_level))
	DebugMaster.log_debug("This is our current experience after levelling: " + str(current_experience_points))
	
	# Its possible we could get enough experience in one go to level up more than once
	level_up_if_possible()


func gain_experience(experience_amount):
	current_experience_points += experience_amount
	level_up_if_possible()
	experience_points_changed.emit()


func get_level() -> int:
	return current_level


func get_experience() -> int:
	return current_experience_points



# ---------- Saving and Loading---------- #


# Function to generate save dictionary
func generate_save_dictionary() -> Dictionary:
	var save_dict = {
		CURRENT_LEVEL_KEY: current_level,
		CURRENT_EXPERIENCE_POINTS_KEY: current_experience_points,
		EQUIPPED_ABILITY_IDS_KEY: generate_equipped_id_list()
	}
	return save_dict


# Function to load from save dictionary
func load_from_save_dictionary(save_dict: Dictionary) -> void:
	if save_dict.has(CURRENT_LEVEL_KEY):
		current_level = save_dict[CURRENT_LEVEL_KEY]
	if save_dict.has(CURRENT_EXPERIENCE_POINTS_KEY):
		current_experience_points = save_dict[CURRENT_EXPERIENCE_POINTS_KEY]
	if save_dict.has(EQUIPPED_ABILITY_IDS_KEY):
		equip_abilities_from_id_list(save_dict[EQUIPPED_ABILITY_IDS_KEY])



# ---------- Getters and Setters ---------- #


func get_equipped_damage_ability() -> RPGAbility:
	return equipped_damage_ability


func get_equipped_crowd_control_ability() -> RPGAbility:
	return equipped_crowd_control_ability


func get_equipped_buff_ability() -> RPGAbility:
	return equipped_buff_ability


func get_equipped_movement_ability() -> RPGAbility:
	return equipped_movement_ability
