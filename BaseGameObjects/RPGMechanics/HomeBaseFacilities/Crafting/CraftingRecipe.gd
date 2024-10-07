class_name CraftingRecipe extends Node

enum storage {STASH, INVENTORY}

@export var item_cost_dictionary : Dictionary = {}
@export var power_cost : int = 0

@export var crafted_item_dictionary : Dictionary = {}

## base_facility_level_required indicates what level the base_facility this crafting
## recipe is used by. This is the level the base facility needs to be to make use
## of this recipe. We save it here in the recipe for ease of use by the base facility.
## We are going to make recipes children of the Base Facility node, and trying to map
## it in a more complex way would be difficult
@export var base_facility_level_required : int = 0

## base_facility is the base_facility which owns us. Can be null
var base_facility : HomeBaseFacility

# ----- Parent Variables ----- #
var parent_category : CraftingCategory = null



# ---------- Ready and Assignment Functions --------- #


func _ready():
	replace_item_cost_node_paths()
	replace_crafted_item_node_paths()


func assign_parent_category(new_parent_category : CraftingCategory) -> void:
	parent_category = new_parent_category


func replace_crafted_item_node_paths():
	var new_dict = {}
	for key in crafted_item_dictionary.keys():
		var quantity = crafted_item_dictionary[key]
		var node = get_node(key)
		new_dict[node] = quantity
	crafted_item_dictionary = new_dict


func replace_item_cost_node_paths():
	var new_dict = {}
	for key in item_cost_dictionary.keys():
		var quantity = item_cost_dictionary[key]
		var node = get_node(key)
		new_dict[node] = quantity
	item_cost_dictionary = new_dict


## Returns an array which collectively contains newly instanced items from crafted_item_dictionary
func create_crafted_items_array():
	var item_array : Array[Item] = []
	
	for my_crafted_item : Item in crafted_item_dictionary.keys():
		var crafted_item_quantity : int = crafted_item_dictionary[my_crafted_item]
		var item_array_for_item = Inventory.create_item_array_from_item_and_quantity(my_crafted_item, crafted_item_quantity	)
		for my_entry in item_array_for_item:
			item_array.append(my_entry)
			
	return item_array


func pay_crafting_cost():
	for item in item_cost_dictionary.keys():
		var remaining_quantity : int = item_cost_dictionary[item]
		var item_id : String = item.item_id
		
		var quantity_in_stash_storage = get_quantity_of_item_in_stash(item_id)
		var quantity_in_player_main_storage = get_quantity_of_item_in_player_storage(item_id)
		
		var quantity_to_take_from_player_storage = min(quantity_in_player_main_storage, remaining_quantity)
		
		InventoryMaster.get_player_main_storage().remove_quantity_of_item_with_item_id(quantity_to_take_from_player_storage, item_id)
		remaining_quantity -= quantity_to_take_from_player_storage
		
		if remaining_quantity > 0:
			var quantity_to_take_from_stash_storage = min(quantity_in_stash_storage, remaining_quantity)
			InventoryMaster.get_player_stash().remove_quantity_of_item_with_item_id(quantity_to_take_from_stash_storage, item_id)


func pay_power_cost():
	PersistentDataTome.set_current_solar_power(PersistentDataTome.get_current_solar_power() - power_cost)


func give_crafted_items(preferred_destination:storage = storage.STASH):
	var crafted_item_array = create_crafted_items_array()
	var stash:Callable = InventoryMaster.get_player_stash
	var inventory:Callable = InventoryMaster.get_player_inventory
	var destination:Callable
	
	match preferred_destination:
		storage.STASH:
			destination = stash if check_crafted_items_fit_in_stash() else InventoryMaster.get_player_inventory
		storage.INVENTORY:
			destination = inventory if check_crafted_items_fit_in_inventory() else InventoryMaster.get_player_stash
	
	destination.call().insert_item_array(crafted_item_array)


## Returns true if this recipe can be crafted; false otherwise
func craft(preferred_destination:storage = storage.STASH) -> bool:
	if check_can_craft():
		pay_power_cost()
		pay_crafting_cost()
		give_crafted_items(preferred_destination)
		return true
	return false


func check_can_craft():
	return check_has_enough_base_power() and check_base_facility_high_enough_level() and check_has_enough_item_quantity() and check_crafted_items_fit()


func check_has_enough_item_quantity():
	for my_item_entry : Item in item_cost_dictionary.keys():
		if get_total_owned_quantity_of_item(my_item_entry.item_id) < item_cost_dictionary[my_item_entry]:
			OnScreenMessageMaster.display_message("Not Enough of: " + str(my_item_entry.display_name))
			return false
	return true


func check_has_enough_base_power():
	if PersistentDataTome.get_current_solar_power() >= power_cost:
		return true
	else:
		OnScreenMessageMaster.display_message("Not Enough Power")


func check_base_facility_high_enough_level():
	if base_facility == null:
		return true
	else:
		return base_facility.current_upgrade_level >= base_facility_level_required


func check_crafted_items_fit():
	if check_crafted_items_fit_in_stash() or check_crafted_items_fit_in_inventory():
		return true
	else:
		OnScreenMessageMaster.display_message("Not Enough Space in Inventory")
		return false


func check_crafted_items_fit_in_stash():
	var crafted_items : Array[Item] = create_crafted_items_array()
	return InventoryMaster.get_player_main_storage().does_item_array_fit(crafted_items)


func check_crafted_items_fit_in_inventory():
	var crafted_items = create_crafted_items_array()
	return InventoryMaster.get_player_inventory().does_item_array_fit(crafted_items)


func assign_base_facility(new_base_facility : HomeBaseFacility):
	base_facility = new_base_facility


func get_quantity_of_item_in_player_storage(item_id: String):
	return InventoryMaster.get_player_main_storage().find_quantity_of_items_with_id(item_id)


## Need to check for null since stash doesn't exist outside of the home base level
func get_quantity_of_item_in_stash(item_id: String):
	var stash = InventoryMaster.get_player_stash()
	if stash:
		return stash.find_quantity_of_items_with_id(item_id)
	return 0


func get_total_owned_quantity_of_item(item_id: String):
	return get_quantity_of_item_in_player_storage(item_id) + get_quantity_of_item_in_stash(item_id)
