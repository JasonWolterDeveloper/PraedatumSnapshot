class_name RPGMechanicsMaster extends Node

signal damage_event_signal

# ----- SAVE CONSTANTS ----- #
const STATS_SAVE_KEY = "stats"
const MORALE_BUFF_MASTER_SAVE_KEY = "morale_buff_master"

# ----- RPG Modifiers ----- #
var passive_ability_list : Array[RPGAbility] = []
var status_effect_list : Array[RPGStatusEffect] = []

var rpg_event_modifier_list : Array[RPGEventModifier] = []
var morale_buff_master : MoraleBuffMaster

# ----- Owner/Parent Information ----- #
@export var is_player_mechanics_master : bool = false

var character : Character:
	get: return Util.get_character_parent(self)

var stat_dictionary : Dictionary = {}

# ----- Frequently Used Stat REferences ----- #
var health:
	get: 
		if stat_dictionary.has("health"):
			return stat_dictionary["health"]
		return null

var mana:
	get: 
		if stat_dictionary.has("mana"):
			return stat_dictionary["mana"]
		return null

var armour:Armour:
	get: return character.get_armour()

var movement_speed:
	get: 
		if stat_dictionary.has("movement_speed"):
			return stat_dictionary["movement_speed"]
		return null

var number_of_morale_buff_slots:
	get:
		if stat_dictionary.has("number_of_morale_buff_slots"):
			return stat_dictionary["number_of_morale_buff_slots"]
		return null


var inventory_storage_height:
	get:
		if stat_dictionary.has("inventory_storage_height"):
			return stat_dictionary["inventory_storage_height"]
		return null

# --------- Stats for use with Enemies ---------
var melee_damage:
	get:
		if stat_dictionary.has("melee_damage"):
			return stat_dictionary["melee_damage"]
		return null

var melee_rate:
	get:
		if stat_dictionary.has("melee_rate"):
			return stat_dictionary["melee_rate"]
		return null

var stunned:
	get: return is_stunned()



# ---------- Ready, Assignment, and Population Functions ---------- #


func _ready():
	populate_stat_dictionary()
	for my_child in get_children():
		if my_child is RPGStatusEffect:
			add_status_effect(my_child)
	add_direct_children_abilities_to_master()
	if is_player_mechanics_master:
		populate_morale_buff_master()


func populate_morale_buff_master():
	morale_buff_master = Util.find_node_by_name(self, "MoraleBuffMaster")
	if morale_buff_master:
		if character is Player:
			morale_buff_master.assign_player(character)
		morale_buff_master.assign_rpg_mechanics_master(self)


# TODO - Probably should be Removed. Its good for easy testing as adding RPGAbilities
# To the RPGMechanicsMaster is easy, but probably should not be in the final game
func add_direct_children_abilities_to_master():
	var ability_list: Array[RPGAbility] = []
	for child in get_children():
		if child is RPGAbility:
			ability_list.append(child)
	add_rpg_ability_list(ability_list)


func populate_stat_dictionary():
	stat_dictionary.clear()
	for my_child in get_children():
		if my_child is RPGStat:
			stat_dictionary[my_child.stat_id] = my_child



# ---------- Functions for adding/removing RPGModifier Holders ---------- #


func on_morale_buffs_changed():
	generate_rpg_event_modifier_list()


func notify_morale_buff_added(morale_buff : MoraleBuff):
	recalculate_stats_for_node(morale_buff)
	on_morale_buffs_changed()


func notify_morale_buff_removed(morale_buff : MoraleBuff):
	recalculate_stats_for_node(morale_buff)
	on_morale_buffs_changed()


## add_rpg_ability_list() takes an array of RPGAbility Objects and adds them to
## the appropriate lists inside of our rpg_mechanics_master. Because RPGAbilities
## impact our stats, we recalculate all of our stats after the end of this function
## Since this is intended to be used to add an entire suite of abilities from a Warrior
## to the RPGMechanicsMaster, we also clear all of our existing ability lists just to be
## safe 
func add_rpg_ability_list(ability_list: Array[RPGAbility]):
	passive_ability_list.clear()
	for ability in ability_list:
		ability.assign_rpg_mechanics_master(self)
		if ability.is_passive:
			passive_ability_list.append(ability)
	recalculate_all_stats()
	generate_rpg_event_modifier_list()


## add_status_effect() takes a status effect object, adds it as a child of ourself which is necessaary
## as status effects can have process functions that need to be run, and does all the work to notify
## the status effect that we are now its rpg_mechanics_master. Our stats are then recalculated in case
## the status effect has any immediate impacts 
func add_status_effect(new_status_effect : RPGStatusEffect):
	new_status_effect.assign_rpg_mechanics_master(self)
	status_effect_list.append(new_status_effect)
	Util.force_add_child(self, new_status_effect)
	new_status_effect.on_status_effect_added()

	if new_status_effect is StunnedStatusEffect:
		character.show_stun_status_effect()
	
	# Only recalculate stats that the status effect has modifiers for
	recalculate_stats_for_node(new_status_effect)
	generate_rpg_event_modifier_list()


## destroy_status_effect() removes a status effect from ourselves and deletes it from the game.
##  Finally, recalculates stats as necessary to reflect changes from loss of status effect
func destroy_status_effect(status_effect: RPGStatusEffect):
	status_effect.on_status_effect_removed()
	remove_child(status_effect)
	Util.delete_object_from_array(status_effect_list, status_effect)
	status_effect.queue_free()

	if status_effect is StunnedStatusEffect:
		character.hide_stun_status_effect()
	
	# Only recalculate stats that the status effect has modifiers for
	recalculate_stats_for_node(status_effect)
	generate_rpg_event_modifier_list()


func add_or_refresh_status_effect(status_effect: RPGStatusEffect):
	for existing_status_effect : RPGStatusEffect in status_effect_list:
		if existing_status_effect.id == status_effect.id:
			existing_status_effect.reset_timer()
			if existing_status_effect.show_added_text_for_refresh:
				existing_status_effect.on_status_effect_added()
			return
	# If we haven't found an existing version of the status effect, we add it
	add_status_effect(status_effect)


# ---------- Generic Functions ---------- #


func find_status_effect_of_type(status_effect_type):
	for my_status_effect in status_effect_list:
		if is_instance_of(my_status_effect, status_effect_type):
			return my_status_effect
	return null


func is_stunned():
	return find_status_effect_of_type(StunnedStatusEffect) != null



# ---------- Functions for Applying RPGStatModifiers ---------- #


## generate_rpg_modifier_list_for_stat(stat) returns an array of all RPGStatModifiers relevant
## to this RPGMechanicsMaster that impact the given stat 
func generate_rpg_modifier_list_for_stat(stat : RPGStat) -> Array[RPGStatModifier]:
	var matching_modifiers : Array[RPGStatModifier] = []
	
	var item_rpg_modifiers_list : Array[Item] = []
	
	if character is Player and character.get_armour():
		item_rpg_modifiers_list.append(character.get_armour())
	if character is Player and character.get_backpack():
		item_rpg_modifiers_list.append(character.get_backpack())
	if character is Player and character.get_equipped_item():
		item_rpg_modifiers_list.append(character.get_equipped_item())
	
	
	# Helper function to check for and add matching modifiers from a given list of RPGStatModifier
	# holders
	var check_and_add_modifiers = func(list):
		for element in list:
			for modifier in element.rpg_stat_modifiers:
				if modifier.stat_id == stat.stat_id:
					matching_modifiers.append(modifier)
	
	# Check all lists of RPGStatModifier holders
	check_and_add_modifiers.call(passive_ability_list)
	check_and_add_modifiers.call(status_effect_list)
	check_and_add_modifiers.call(item_rpg_modifiers_list)
	if morale_buff_master:
		check_and_add_modifiers.call(morale_buff_master.active_morale_buffs)
	
	return matching_modifiers


## Generates a list of all of the RPGStats in this RPGMechanics master that are modified by the
## given node whether the node be an RPGAbility or a Status Effect or what have you
func generate_modified_stat_list(node: Node) -> Array[RPGStat]:
	var stat_list : Array[RPGStat] = []
	
	# Assuming the node has a method or property to access its RPG modifier list
	#if node.has
	var modifiers = node.rpg_stat_modifiers
	
	for modifier in modifiers:
		if stat_dictionary.has(modifier.stat_id):
			stat_list.append(stat_dictionary[modifier.stat_id])  # Keep the list of stat IDs (not necessarily unique)

	return stat_list


## recalculate_stats_for_node() takes a node that hold RPGStatModifiers and recalculates all stats
## that it has modifiers for
func recalculate_stats_for_node(node: Node) -> void:
	# Get the array of modified stats
	var stat_list : Array[RPGStat] = generate_modified_stat_list(node)
	
	# Iterate over each stat and recalculate it
	for stat : RPGStat in stat_list:
		stat.recalculate_stat_value()


## on_equip_item(item) takes an item object and does everything the RPGMechanicsMaster needs to do
## if the player just equipped this item, most notably recalculating stats
func on_equip_item(item : Item):
	recalculate_stats_for_node(item)


func recalculate_all_stats():
	for key in stat_dictionary.keys():
		var stat = stat_dictionary[key]
		stat.recalculate_stat_value()



# ---------- Functions for Applying RPGEventModifiers ---------- #


## generate_rpg_event_modifier_list(stat) returns an array of all RPGEventModifiers relevant
## to this RPGMechanicsMaster
func generate_rpg_event_modifier_list() -> void:
	rpg_event_modifier_list.clear()
	
	# Helper function to check for and add matching modifiers from a given list of RPGStatModifier
	# holders
	var add_modifiers = func(list):
		for element in list:
			for modifier in element.rpg_event_modifiers:
				modifier.assign_character(character)
				rpg_event_modifier_list.append(modifier)
	
	# Check all lists of RPGStatModifier holders
	add_modifiers.call(passive_ability_list)
	add_modifiers.call(status_effect_list)


func apply_event_modifiers_to_event(event : RPGEvent):
	for modifier :RPGEventModifier in rpg_event_modifier_list:
		modifier.apply_to_event(event)



# ---------- Saving/Loading Functions ---------- #

## copy_base_stats_to_RPG_mechanics_master() copies all of the stat base values from this
## rpg_mechanics_master to another. This is primarily used to copy the base stats from a particular
## Warrior to the player.
func copy_base_stats_to_RPG_mechanics_master(rpg_mechanics_master : RPGMechanicsMaster) -> void:
	for my_stat_id in stat_dictionary.keys():
		if rpg_mechanics_master.stat_dictionary.has(my_stat_id):
			var my_stat : RPGStat = stat_dictionary[my_stat_id]
			var their_stat : RPGStat = rpg_mechanics_master.stat_dictionary[my_stat_id]
			my_stat.copy_base_values_to_stat(their_stat)


func generate_save_dictionary():
	var save_dictionary = {}
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
		
	var stat_save_dictionary : Dictionary = {}
	save_dictionary[STATS_SAVE_KEY] = stat_save_dictionary
		
	for my_stat_id in stat_dictionary.keys():
		stat_save_dictionary[my_stat_id] = stat_dictionary[my_stat_id].generate_save_dictionary()
		
	if morale_buff_master:
		save_dictionary[MORALE_BUFF_MASTER_SAVE_KEY] = morale_buff_master.generate_save_dictionary()

	return save_dictionary


func load_from_dictionary(load_dictionary):
	if MORALE_BUFF_MASTER_SAVE_KEY in load_dictionary and morale_buff_master:
		morale_buff_master.load_from_dictionary(load_dictionary[MORALE_BUFF_MASTER_SAVE_KEY])
	if STATS_SAVE_KEY in load_dictionary:
		var stat_load_dictionary = load_dictionary[STATS_SAVE_KEY]
	
		for stat_id in stat_load_dictionary:
			if stat_dictionary.has(stat_id):
				stat_dictionary[stat_id].load_from_dictionary(stat_load_dictionary[stat_id])
	
