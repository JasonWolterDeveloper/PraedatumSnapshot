class_name HomeBaseFacility extends Node

const CURRENT_LEVEL_SAVE_KEY = "current_level"

var current_upgrade_level : int = 0
@export var max_upgrade_level : int = 0

# The upgrade cost per level in an array. NOTE we are storing item costs as actual
# item objects so that we have access to the display names, inventory images
# descriptions and anything else we need from the inventory item. We will also
# store the item in a size 2 array with its cost as an integer beside it, like so:

# [[], [[ScrapMetal, 5], [ScienceDoohickey, 2]]]

# NOTE I haven't bothered storing this in an export because every home base facility
# will need its own script and it's probably safer to put this in code
var upgrade_cost_per_level : Array[Array] = [[]] # Empty Array added because cost of level 0 should be nothing

## base_facility_id is used to identify the base facility for saving and loading
@export var base_facility_id : String = ""

## is_usable_facility indicates whether or not this facility should have a use button at all
## It does not indicate whether or not the facility can be used at this exact moment and is primarily
## used for the UI
@export var is_usable_facility : bool = false

@export var display_name : String = ""
@export_multiline var description : String = ""


@export var top_level_crafting_category : CraftingCategory
var crafting_recipe_list : Array = []
var upgrade_recipe_list : Array = []


func _ready():
	populate_crafting_recipes()
	populate_upgrade_recipes()


func can_upgrade():
	return get_upgrade_recipe_for_next_level() != null


func upgrade(upgrade_level : int):
	current_upgrade_level = max(current_upgrade_level, upgrade_level)


## handle_previous_raid() does whatever a facility should do when the hub level is entered
## after a raid automatically, such as refilling health. Must be overridden
func handle_previous_raid():
	pass


## on_hub_level_entered() should do what the facility should do every time the Hub level
## starts, both when you simply launch the game as well as when you finish a raid, such as
## resizing the stash storage
func on_hub_level_entered():
	pass


## can_use_facility() returns true if the facility is currently usable and false otherwise
func can_use_facility():
	return true


## use_facility is a function that can be called publically that enacted the use
## facility effect if the facility is currently usable
func use_facility():
	if can_use_facility():
		use_facility_effect()


## use_facility_effect is a function that should be overridden to do whatever it
## is the facility is meant to do when it is used
func use_facility_effect():
	pass


## Generates an array of all crafting recipes at the given upgrade level
func generate_crafting_recipe_list_for_level(upgrade_level : int):
	var crafting_array : Array[CraftingRecipe] = []
	for my_recipe : CraftingRecipe in crafting_recipe_list:
		if my_recipe.base_facility_level_required == upgrade_level:
			crafting_array.append(my_recipe)
			
	return crafting_array


func get_upgrade_recipe_for_next_level():
	var next_upgrade_level = current_upgrade_level + 1
	
	for my_recipe : BaseUpgradeRecipe in upgrade_recipe_list:
		if my_recipe.upgrade_for_level == next_upgrade_level:
			return my_recipe


## Finds all of the crafting recipes and assigns them to our crafting recipe
## array
func populate_crafting_recipes(node = self):
	if node == self:
		crafting_recipe_list.clear()
	if node is CraftingRecipe and not node is BaseUpgradeRecipe:
		crafting_recipe_list.append(node)
		node.assign_base_facility(self)
	for my_child in node.get_children():
		populate_crafting_recipes(my_child)


func populate_upgrade_recipes(node = self):
	if node == self:
		upgrade_recipe_list.clear()
	if node is BaseUpgradeRecipe:
		upgrade_recipe_list.append(node)
		node.assign_base_facility(self)
	for my_child in node.get_children():
		populate_upgrade_recipes(my_child)


func generate_save_dictionary():
	var save_dictionary = {}
	
	save_dictionary[CURRENT_LEVEL_SAVE_KEY] = current_upgrade_level
	
	return save_dictionary


func load_from_dictionary(load_dictionary):
	if load_dictionary.has(CURRENT_LEVEL_SAVE_KEY):
		current_upgrade_level = load_dictionary[CURRENT_LEVEL_SAVE_KEY]


func save_to_persistent_data_tome():
	PersistentDataTome.set_data_for_base_facility_by_id(base_facility_id, generate_save_dictionary())


func load_from_persistent_data_tome():
	var load_dictionary = PersistentDataTome.get_data_for_base_facility_by_id(base_facility_id)
	
	if load_dictionary:
		load_from_dictionary(load_dictionary)


## Returns true if this facility has any crafting recipes
func is_crafting_facility():
	return not crafting_recipe_list.is_empty()


func get_upgrade_cost_for_level(upgrade_level : int) -> Array:
	return upgrade_cost_per_level[upgrade_level]


func get_item_from_upgrade_cost_entry(upgrade_cost_entry : Array):
	return upgrade_cost_entry[0]


func get_quantity_from_upgrade_cost_entry(upgrade_cost_entry: Array):
	return upgrade_cost_entry[1]


func get_max_upgrade_level():
	return max_upgrade_level
