class_name Item extends InventoryObject

signal changed

const GRID_POSITION_SAVE_KEY = "grid_position"

var item_owner : Character :
	get: return Util.get_character_parent(self)

# Where this item is located within an inventory. If this item isn't in an 
# inventory these values are irrelevent
@export var grid_position = Vector2(0, 0)
@export var inventory_image : Texture = null
@export var ground_3d_model_scene : PackedScene
@export var display_name : String = ""
## item_id is a unique identifier that will allow us to search the inventory for other items of this type
@export var item_id : String
## A string indicating what animation state the palyer should use with this item equipped
@export var player_pose : String = ""
@export_multiline var description = ""

## usable_from_inventory should be set to true if we can use the item from the inventory and false
## otherwise
@export var usable_from_inventory : bool = false

@export var show_quantity_in_ui = false

var use_pressed : bool = false
var alt_use_pressed : bool = false

enum item_types {
	GENERIC,
	WEAPON,
	AMMO,
	UTILITY,
	ARMOUR,
	BACKPACK,
	UPGRADE
}

@export var default_price : int = 1


@export var item_type : item_types
@export var item_stat_entry_collection : ItemStatEntryCollection

@export var delete_at_zero_quantity : bool = true

@export var current_quantity = 1 :
	set(value):
		current_quantity = value
		changed.emit()
		if delete_at_zero_quantity and current_quantity == 0:
			# TODO: Doing this this way because otherwise the UI won't detect
			# that we are no longer in the inventory, as queue_free has not been
			# run yet
			if get_parent() is ItemHolder:
				get_parent().remove(self)
			queue_free()
@export var max_quantity = 1

@export var rpg_tags: RPGTags = null

@export var rpg_stat_modifiers: Array[RPGStatModifier] = []
@export var rpg_event_modifiers: Array[RPGEventModifier] = []


func _ready():
	# rpg_tags are mandatory
	if not rpg_tags:
		rpg_tags = RPGTags.new()
	pass



# --------- Equip and Use Functions ---------- #


## Returns true if the player can requip this and false otherwise
func is_equippable() -> bool:
	return self is Weapon or self is UtilityItem


# Run every frame the item is equipped
func handle_equipped(delta : float):
	pass


## Function for item use. For a gun that might be pulling the trigger
func on_use_item_pressed():
	use_pressed = true


func on_use_item_released():
	use_pressed = false


func on_alt_use_item_pressed():
	alt_use_pressed = true


func on_alt_use_item_released():
	alt_use_pressed = false


## use_from_inventory is the function that is called when the use button is
## clicked from the inventory. Usually this will simply do whatever should be done
## when use item is pressed, but oftentimes we will want to override it
func use_from_inventory():
	on_use_item_pressed()


## can_use_from_inventory returns true if we can use this item from our inventory.
## Usually this will match our exported variable, but often times some other conditions,
## such as being in the HubLevel will need to be met for you to be able to use an item
func can_use_from_inventory():
	return usable_from_inventory


# --------- Inventory Functions ---------- #


# generate_inventory_rect returns a rectangle which represents how big this 
# item is in the grid inventory in grid squares. This is used for several purposes
# such as detecting collisions in the inventory
func generate_inventory_rect():
	return Rect2(grid_position, Vector2(grid_square_width, grid_square_height))


# getGridLocationFromCenter(center) takes in a grid square indicating where the "center" of this item should be in
# an inventory grid and returns the grid square that should be set as the item's location in the inventory grid
# such that its center is at the given grid square. This is used in the inventory UI, as objects are dragged by
# their centers and therefore the inventoryUI knows where the center gridsquare should be, but, due to the way the
# inventory functions, locations need to be set by the top left grid square, which is what this returns.
func calculate_grid_location_from_center(center):
	return Vector2(center[0] - grid_square_width/2, center[1] - grid_square_height/2)


# interact_with_item(item) takes in another item object and performs
# this item's default interaction with it. for a weapon attachment with a
# weapon that could be attaching the attachment. For an ammo object that
# could be stacking the two ammo objects. Returns true if this removes the item
# from its current inventory slot and false otherwise
func interact_with_item(item: Item) -> bool:
	return false


func can_interact_with_item(item: Item):
	return false


# return the item holder that this item belongs to
func get_item_holder(node = self):
	if node == null:
		return null
	if not node is ItemHolder:
		return get_item_holder(node.get_parent())
	else:
		return node


func can_stack_with_item(item : Item):
	return false
	
	
func can_stack_with_item_no_leftovers(item: Item):
	if item and item.delete_at_zero_quantity and can_stack_with_item(item):
		return current_quantity + item.current_quantity <= max_quantity
	return false


# Stacks this quantity item on top of another quantity item, deleting this quantity item
# if the combined quantities of both items don't reach the maximum stack size
# returns true if this item will be consumed by the action and false otherwise
func stack(item: QuantityItem) -> bool:
	var missing_quantity = item.calculate_missing_quantity()
	if missing_quantity > current_quantity:
		item.current_quantity += current_quantity
		current_quantity = 0
		return true
	else:
		item.current_quantity = item.max_quantity
		current_quantity -= missing_quantity
		return false



# --------- RPG Stat References ---------- #


func apply_event_modifiers_to_event(event : RPGEvent):
	for modifier :RPGEventModifier in rpg_event_modifiers:
		modifier.apply_to_event(event)



# --------- Aesthetic Functions ---------- #


# generate_quantity_string() generates a string that is used to display the 
# quantity of this item in the inventory menu
func generate_quantity_string():
	return str(current_quantity) # +"/" + str(max_quantity) 


func generate_pickup_message():
	return "Picked Up " + display_name


func generate_ground_3d_model():
	if ground_3d_model_scene:
		return ground_3d_model_scene.instantiate()
	return null



# --------- Saving and Loading Functions ---------- #


func load_from_dictionary(load_dictionary):
	grid_position.x = load_dictionary[GRID_POSITION_SAVE_KEY][0]
	grid_position.y = load_dictionary[GRID_POSITION_SAVE_KEY][1]


func generate_save_dictionary():
	var save_dictionary = super()
	
	save_dictionary[GRID_POSITION_SAVE_KEY] = [grid_position.x, grid_position.y]
	
	return save_dictionary



# --------- Other Functions --------- #


# Takes a minimum and maximum value. If minimum is under 1 it will be set to 1
# If maximum is over maximum_quantity it will be set to maxmimum quantity such
# that randomizing the quantity will never give us less than 1 quantity or more
# than the maximum amount we can hold. Current quantity will be set to the result
func randomize_quantity(min_amount : int = 1, max_amount : int = max_quantity):
	var final_min_amount = max(min_amount, 1)
	var final_max_amount = min(max_amount, max_quantity)
	var random_value = randi_range(final_min_amount, final_max_amount)
	
	current_quantity = random_value


# ---------- Getters --------- #

func get_rpg_stat_modifiers():
	return rpg_stat_modifiers

"""

func getMaxQuantity():
	return getItem().getMaxQuantity()

func getQuantity():
	return getItem().getQuantity()

func getSmartStack():
	return getItem().getSmartStack()
"""
