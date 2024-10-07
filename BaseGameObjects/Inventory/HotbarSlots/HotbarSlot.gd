class_name HotbarSlot extends Node

# ----- Save Constants ----- $
const SLOT_IDX_SAVE_KEY = "slot_idx"
const ITEM_ID_SAVE_KEY = "item_id"
const GRID_POSITION_SAVE_KEY = "grid_position"

# ----- Identifier References ----- #
var slot_idx : int = 0
var is_equipped : bool = false

# ----- Item References ----- #
var item: Item
var item_id: String = ""
var grid_position: Vector2

# ----- Owner and Parent References ----- #
var inventory : Inventory

# ----- Signals ----- #
signal hot_bar_changed



# ---------- Ready and Assignment Functions --------- #


# Function to assign inventory to the hot bar slot
func assign_inventory(new_inventory):
	inventory = new_inventory


func assign_idx(new_idx : int):
	slot_idx = new_idx


## Assigns the item to this hotbar slot, only if it meets the appropriate criteria
## such as the item existing in the inventory
func attempt_assign_item(new_item : Item) -> void:
	if inventory.has_given_item(new_item) and new_item.is_equippable():
		assign_item(new_item)


# Function to assign an item to the hot bar slot
func assign_item(new_item: Item):
	item = new_item
	update_from_current_item()


# Used on load to grab item from grid and id
func assign_item_from_grid_and_id():
	if item_id != "" and grid_position != null:
		var new_item : Item = inventory.main_storage.get_item_at_grid_position(grid_position)
		if new_item and new_item.item_id == item_id:
			assign_item(new_item)



# --------- Item Management Functions --------- #


## Update() performs all functions we need to perform in the hotbar if the hotbar has changed
func update():
	if item:
		# Try to find the item in the inventory using the item object
		var inventory_has_item = inventory.has_given_item(item)
		if inventory_has_item:
			update_from_current_item()
			return
		else:
			# If the above fails or item is not available, try to find the item using item ID
			var similar_item = find_item_with_same_item_id()
			if similar_item:
				# NOTE this needs to be done first otherwise assign_item will overwrite uss
				if is_equipped: # If we're equipped set this as our inventory's new equipped item.
					inventory.equipped_item = similar_item
					inventory.equipped_item_changed.emit(similar_item)
				assign_item(similar_item)
				return
	# If both attempts fail, reset the item
	reset_item()


func find_item_with_same_item_id():
	return inventory.find_item_with_id(item_id)


# Function to update the item's ID and grid position from the item
func update_from_current_item():
	if item:
		# Update the item's ID and grid position
		item_id = item.item_id
		grid_position = item.grid_position
		
		if inventory and inventory.equipped_item == item:
			is_equipped = true
		else:
			is_equipped = false
			
		hot_bar_changed.emit()
	else:
		reset_item()


func reset_item():
	item = null
	item_id = ""
	grid_position = Vector2(-1, -1)
	is_equipped = false
	hot_bar_changed.emit()



# ---------- Saving and Loading Functions ---------- #


func generate_save_dictionary() -> Dictionary:
	var save_dictionary : Dictionary = {}
	save_dictionary[SLOT_IDX_SAVE_KEY] = slot_idx
	save_dictionary[ITEM_ID_SAVE_KEY] = item_id
	save_dictionary[GRID_POSITION_SAVE_KEY] = [grid_position.x, grid_position.y]
	
	return save_dictionary


func load_from_dictionary(load_dictionary : Dictionary) -> void:
	# Checking if this is the right dictionary for the hotbar slot
	if load_dictionary.has(ITEM_ID_SAVE_KEY):
		item_id = load_dictionary[ITEM_ID_SAVE_KEY]
	if load_dictionary.has(GRID_POSITION_SAVE_KEY):
		grid_position.x = load_dictionary[GRID_POSITION_SAVE_KEY][0]
		grid_position.y = load_dictionary[GRID_POSITION_SAVE_KEY][1]
		
		# Grid required to load from save
		assign_item_from_grid_and_id()
			
