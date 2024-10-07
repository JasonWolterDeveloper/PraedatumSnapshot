## InventoryMaster is a global singleton used to access the player's inventory
## and stash from any other place in the game

extends Node


var player_inventory : Inventory
var stash : StashStorage
var lost_and_found : LostAndFoundStorage


func assign_player_inventory(new_inv : Inventory):
	player_inventory = new_inv


func assign_stash(new_stash : StashStorage):
	stash = new_stash


func assign_lost_and_found(new_lost_and_found : LostAndFoundStorage):
	lost_and_found = new_lost_and_found


func get_player_inventory() -> Inventory:
	if is_instance_valid(player_inventory):
		return player_inventory
	return null


func get_player_main_storage() -> Storage:
	if is_instance_valid(player_inventory):
		return player_inventory.main_storage
	return null


func get_player_stash() -> StashStorage:
	if is_instance_valid(stash):
		return stash
	return null


func get_lost_and_found() -> LostAndFoundStorage:
	if is_instance_valid(lost_and_found):
		return lost_and_found
	return null


func player_inventory_has_quantity_of_item_by_item_id(item_id : String, quantity: int):
	if get_player_inventory():
		return get_player_inventory().find_quantity_of_items_with_id(item_id) >= quantity
	return false
	
	
func player_stash_has_quantity_of_item_by_item_id(item_id : String, quantity: int):
	if get_player_stash():
		return get_player_stash().find_quantity_of_items_with_id(item_id) >= quantity
	return false
   

######### Remove Item Functions ##########

##### By Id #####

## remove_quantity_of_item_with_item_id_from_player_inventory returns 0 if the inventory has enough quantity to
## remove and the quantity remaining otherwise. Always removes items
func remove_quantity_of_item_with_item_id_from_player_inventory(quantity : int, item_id : String) -> int:
	var quantity_remaining : int = quantity
	if get_player_inventory():
		quantity_remaining = max(0, quantity - get_player_inventory().find_quantity_of_items_with_id(item_id))
		get_player_inventory().remove_quantity_of_item_with_item_id(quantity, item_id)
	return quantity_remaining
		
		
func remove_quantity_of_item_with_item_id_from_player_stash(quantity : int, item_id : String):
	var quantity_remaining : int = quantity
	if get_player_stash():
		quantity_remaining = max(0, quantity - get_player_stash().find_quantity_of_items_with_id(item_id))
		get_player_stash().remove_quantity_of_item_with_item_id(quantity, item_id)
	return quantity_remaining
 
 
func remove_quantity_of_item_with_item_id_from_player_inventory_and_stash(quantity : int, item_id: String):
	var quantity_remaining = remove_quantity_of_item_with_item_id_from_player_inventory(quantity, item_id)
	if quantity_remaining:
		quantity_remaining = remove_quantity_of_item_with_item_id_from_player_stash(quantity_remaining, item_id)
	return quantity_remaining


########## Add Item Functions ##########


func add_item_inventory_and_stash_and_lost_and_found_overflow(item : Item):
	if get_player_inventory() and get_player_inventory().can_fit_anywhere(item):
		get_player_inventory().insert_anywhere(item)
	elif get_player_stash() and get_player_stash().can_fit_anywhere(item):
		get_player_stash().insert_anywhere(item)
	elif get_lost_and_found():
		get_lost_and_found().insert_anywhere(item)
	
