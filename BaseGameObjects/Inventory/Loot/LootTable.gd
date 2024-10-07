class_name LootTable extends Node

const DEFAULT_LOOT_ENTRY_WEIGHT = 1

## The number of rolls the corresponding loot object gets on this table
## Defined in the loot table for ease of use, exported as this will oftne
## need changing for the loot object
@export var number_of_rolls : int = 1
## Set min number of rolls to a number other than -1 to have a randomized number of
## rolls on this loot table between min_number_of_rolls and number_of_rolls
@export var min_number_of_rolls : int = -1

@onready var spawn_string_mapper : SpawnStringMapper = $SpawnStringMapper:
	get:
		return PraedatumGlobalLootSpawnStringMapper

# Loot Entries is an array of arrays. Each Array is a loot_entry that contains
# certain information about a piece of loot that could be spawned by this table
var loot_entries : Array = []
var loot_entry_cumulative_weights : Array = [] # Calculated in Ready Function
var total_loot_entry_weight : int = 0 # Calculated in Ready Function
var loot_entry_weights : Dictionary = {}


func _ready():
	# Change loot arrays here
	generate_loot_table_cumulative_and_total_weights()


func roll_loot_table_for_item() -> Item:
	var loot_entry = weighted_roll_for_loot_entry()
	
	if loot_entry != null:
		return generate_loot_item_from_loot_entry(loot_entry)
	return null


## Select Number of Rolls either returns number_of_rolls if min_number_of_rolls is -1
## or picks a number between min number of rolls and number of rolls otherwise
func select_number_of_rolls():
	if min_number_of_rolls == -1:
		return number_of_rolls
	return randi_range(min_number_of_rolls, number_of_rolls)


## Conducts the total number of rolls indicated in this loot_table and returns
## an array with that many item objects in it
func roll_loot_table_for_item_array() -> Array[Item]:
	var loot_item_array : Array[Item] = []
	for x in range(select_number_of_rolls()):
		loot_item_array.append(roll_loot_table_for_item())
		
	return loot_item_array


## Selects a loot_entry from our array of loot_entries randomly, but using the
## given weights for the loot_entries
func weighted_roll_for_loot_entry():
	if not loot_entries.is_empty():
		# Generate a random number between 0 and total_weight
		var rnd = randf_range(0, total_loot_entry_weight)
		
		# Find the item that corresponds to the random number
		for i in range(loot_entry_cumulative_weights.size()):
			if rnd < loot_entry_cumulative_weights[i]:
				return loot_entries[i]
		return loot_entries[0]
	return null


func generate_loot_item_from_loot_entry(loot_entry : Array) -> Item:
	# If we have an empty array as our loot entry, we can't spawn a loot item
	if loot_entry.size() <= 0:
		return null
	
	# Instantiating the Item based on mapping the first index of loot entry, which
	# should be a string, to a packed scene, using the loot_table's spawnstringmapper
	var item_scene = get_packed_scene_from_spawn_string(loot_entry[0])
	var my_item : Item = item_scene.instantiate()
	
	# If our loot_entry size is greater than 1, it means we also have a randomized
	# quantity range as part of our loot_entry, represented as a vector2
	if loot_entry.size() > 1:
		var loot_entry_rand_range : Vector2 = loot_entry[1]
		my_item.randomize_quantity(loot_entry_rand_range.x, loot_entry_rand_range.y)
		
	return my_item


func get_packed_scene_from_spawn_string(spawn_string : String) -> PackedScene:
	if spawn_string_mapper.spawn_string_to_scene_dictionary.has(spawn_string):
		return spawn_string_mapper.spawn_string_to_scene_dictionary[spawn_string]
	return null


func get_weight_for_loot_entry(loot_entry : Array):
	if loot_entry_weights.has(loot_entry):
		return loot_entry_weights[loot_entry]
	return DEFAULT_LOOT_ENTRY_WEIGHT


func generate_loot_table_cumulative_and_total_weights():
	total_loot_entry_weight = 0
	for loot_entry in loot_entries:
		total_loot_entry_weight += get_weight_for_loot_entry(loot_entry)
		loot_entry_cumulative_weights.append(total_loot_entry_weight)
