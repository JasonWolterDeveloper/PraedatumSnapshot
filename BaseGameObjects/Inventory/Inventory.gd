class_name Inventory extends Node3D

# The Inventory objects holds a set of storages and loadout slots that make up
# a single player or entity's inventory. This node is primarily a helper node
# to make accessing player inventories all happen through one node

signal equipped_item_changed(item:Item)

const MAIN_STORAGE_SAVE_KEY = "main_storage"

const ARMOUR_SLOT_SAVE_KEY = "armour_slot"
const BACKPACK_SLOT_SAVE_KEY = "backpack_slot"

const EQUIPPED_ITEM_SAVE_KEY = "equipped_item_grid_location"
const HOTBAR_SLOT_SAVE_KEY = "hotbar_slots"

var ground_item_scene = preload("res://Content/Default/Code/InteractableObjects/GroundItem.tscn")
var hot_bar_slot_scene = preload("res://BaseGameObjects/Inventory/HotbarSlots/HotbarSlot.tscn")

@onready var main_storage : Storage = $MainStorage
@onready var armour_slot : LoadoutSlot = $ArmourSlot
@onready var backpack_slot : LoadoutSlot = $BackpackSlot


# ----- Default Size Variables ----- #
@export var default_grid_height : int = 5
@export var default_grid_width : int = 6

# ---- Equipment Variables ----- #
var equipped_item: Item

# Array to store the generated hot bar slots
var hot_bar_slots: Array[HotbarSlot] = []


# ---------- Ready and Assignment Functions ---------- #


func _ready():
	# Since we should only ever have one inventory since we should only ever have
	# one player, it should be fine to assign this to the inventory master on ready
	assign_to_inventory_master()
	
	generate_hot_bar_slots()
	
	for my_child in get_children():
		if my_child is Item:
			insert_anywhere(my_child)


func assign_to_inventory_master():
	InventoryMaster.assign_player_inventory(self)


func _process(delta):
	pass
	"""
	if Input.is_action_just_pressed("debug_1"):
		clear()
	if Input.is_action_just_pressed("debug_2"):
		magazine_repack()
	"""


# Function to generate hot bar slots and store them in an array
func generate_hot_bar_slots():
	# Clear the existing array
	hot_bar_slots.clear()
	
	# Generate 10 instances of the hot bar slot scene
	for i in range(10):
		var slot_instance : HotbarSlot = hot_bar_slot_scene.instantiate()
		hot_bar_slots.append(slot_instance)
		slot_instance.assign_inventory(self)
		slot_instance.assign_idx(i)



# ---------- Change Handlers ---------- #


func on_inventory_changed():
	# We update hot bar slots first because here is where we will auto re-equip
	# a new item varient if need be
	update_all_hot_bar_slots()
	if not has_given_item(equipped_item):
		reset_equipped_item()
	if GameMaster.get_player():
		GameMaster.get_player().rpg_mechanics_master.recalculate_all_stats()


func reset_equipped_item() -> void:
	equipped_item = null
	equipped_item_changed.emit(equipped_item)


func update_all_hot_bar_slots() -> void:
	for slot in hot_bar_slots:
		slot.update()


# TODO - This function is a bit cringe as we need to call a different loadout slot (update inventory
# size) function than we normally do for other loadout slots (on_inventory_chnged). That isn't the
# worst thing in the world as we do call it at the end here, but it is a little odd compared to how
# we usually do it
func update_inventory_size() -> void:
	var backpack : Backpack = get_backpack()
	var morale_inventory_width_addition : int = get_rpg_mechanics_master().morale_buff_master.get_max_inventory_width_addition()
	if backpack:
		main_storage.grid_square_height = max(default_grid_height, backpack.storage_height)
	else:
		main_storage.grid_square_height = default_grid_height
	main_storage.grid_square_width = default_grid_width + morale_inventory_width_addition
	
	store_non_fitting_items()
	on_inventory_changed()


# Loops through all of the items in our main storage and if one doesn't fit at its
# current position, try to store it, put it in lost and found, or drop it
func store_non_fitting_items():
	var item_list = main_storage.get_items()
	for item : Item in item_list:
		if not main_storage.can_fit(item, item.grid_position):
			store_or_lost_and_found_item(item)


func on_inventory_size_changed() -> void:
	update_inventory_size()



# ---------- Item Management --------- #


func has_given_item(item : Item) -> bool:
	return main_storage.has_given_item(item)


# returns the first item with item_id or null
func find_item_with_id(item_id: String):
	return main_storage.find_item_with_id(item_id)


# store_or_lost_and_found_item() takes an item and attempts to put it into the level's stash or
# lost and found, and drops it otherwise
func store_or_lost_and_found_item(item : Item):
	var level : Level = GameMaster.get_level()
	if level is HubLevel:
		if level.stash_storage.can_fit_anywhere(item):
			level.stash_storage.insert_anywhere(item)
			return
		if level.lost_and_found_storage.can_fit_anywhere(item):
			level.lost_and_found_storage.insert_anywhere(item)
			OnScreenMessageMaster.display_message("Item moved to Lost and Found")
			return
	drop_item(item, false)



# ---------- Equipped Item Management ---------- #


func equip_item(item : Item) -> void:
	if equipped_item != item:
		equipped_item = item
		equipped_item_changed.emit(item)
		on_inventory_changed()


## Unequips the current item regardless of what item that is
func unequip_item() -> void:
	equipped_item = null
	equipped_item_changed.emit(equipped_item)
	on_inventory_changed()


func get_hotbar_slot_by_index(index : int):
	if 0 <= index and index < len(hot_bar_slots):	
		return hot_bar_slots[index]
	return null


func can_equip(item : Item):
	if item and has_given_item(item):
		return item.is_equippable()
	return false


func attempt_equip_hotbar_slot_by_index(index : int):
	var hotbar_slot : HotbarSlot = get_hotbar_slot_by_index(index)
	if hotbar_slot:
		if can_equip(hotbar_slot.item):
			equip_item(hotbar_slot.item)



# ---------- Utility Functions --------- #


func drop_item(item : Item, should_update_inventory_size : bool = true):
	if GameMaster.get_level() and GameMaster.get_player():
		var new_ground_item : InteractableObject = ground_item_scene.instantiate()
		Util.force_add_child(new_ground_item, item)
		Util.force_add_child(GameMaster.get_level(), new_ground_item)
		new_ground_item.global_position = GameMaster.get_player().global_position
		new_ground_item.global_position.y = 0.1
		new_ground_item.assign_camera(GameMaster.get_level().camera)
		
		# Running update_inventory_size here instead of on_inventory_changed() just in case it is our
		# backpack that we dropped
		if should_update_inventory_size:
			update_inventory_size()
		else: 
			on_inventory_changed()


func clear():
	for item_holder in get_item_holders():
		item_holder.clear()


# Repacks all magazines by highest cap first 
func magazine_repack():
	var ammo_types = []
	
	# find all ammo_types in inventory
	for my_item in get_items():
		if my_item is Magazine:
			if not my_item.ammo_type in ammo_types:
				ammo_types.append(my_item.ammo_type)
				
	for ammo_type in ammo_types:
		magazine_repack_for_ammo_type(ammo_type)


# Repacks magazines for a single ammo_type by highest cap first
func magazine_repack_for_ammo_type(ammo_type):
	var total_rounds = 0
	var magazine_list = []
	
	# First loops through the item lists geting an array of all the magazines with 
	# the given ammo type, and how many bullets they have total.
	for my_item in get_items():
		if my_item is Magazine and my_item.ammo_type == ammo_type:
			total_rounds += my_item.current_quantity
			my_item.current_quantity = 0
			magazine_list.append(my_item)
		
	# The magazines are then ordered based on maximum capacity	
	magazine_list.sort_custom(Magazine.magazine_capacity_sort)
	
	# The second loop distributes the rounds between the magazines by highest capacity first
	for my_magazine in magazine_list:
		if total_rounds > my_magazine.max_quantity:
			my_magazine.current_quantity = my_magazine.max_quantity
			total_rounds -= my_magazine.max_quantity
		else:
			my_magazine.current_quantity = total_rounds
			total_rounds = 0
			break


func get_items():
	return main_storage.get_items()


func get_item_holders():
	var item_holders = []
	for my_child in get_children():
		if my_child is ItemHolder:
			item_holders.append(my_child)
	return item_holders


func get_armour() -> Armour:
	return armour_slot.get_item()


func get_backpack() -> Backpack:
	return backpack_slot.get_item()


func can_fit_anywhere(new_item : Item, storage_only = false):
	if storage_only:
		if main_storage.can_fit_anywhere(new_item):
			return true
		return false
	else:
		if main_storage.can_fit_anywhere(new_item):
			return true
		return false


func storage_can_fit_anywhere(new_item : Item):
	if main_storage.can_fit_anywhere(new_item):
		return true
	return false


func insert_anywhere(new_item : Item, storage_only = false):
	if storage_only:
		if main_storage.can_fit_anywhere(new_item):
			main_storage.insert_anywhere(new_item)
	else:
		if armour_slot.can_fit_anywhere(new_item):
			armour_slot.insert_anywhere(new_item)
		elif main_storage.can_fit_anywhere(new_item):
			main_storage.insert_anywhere(new_item)


func storage_insert_anywhere(new_item : Item):
	if main_storage.can_fit_anywhere(new_item):
		main_storage.insert_anywhere(new_item)


func find_all_items_of_type_in_storage(type):
	return main_storage.find_all_items_of_type(type)


## Must pass a class object, NOT an instance of a class (and you can't extract the class from an 
## instance - use find_quantity_of_items_with_id() instead).
func calculate_quantity_of_item_type(type):
	var item_array = find_all_items_of_type_in_storage(type)
	var total_quantity = 0
	
	for my_item : Item in item_array:
		total_quantity += my_item.current_quantity
		
	return total_quantity


func find_quantity_of_items_with_id(item_id : String) -> int:
	return main_storage.find_quantity_of_items_with_id(item_id)


func remove_quantity_of_item_type(quantity : int, type):
	var item_array : Array[Item] = find_all_items_of_type_in_storage(type)
	var removal_array : Array[Item] = []
	var quantity_left_to_remove = quantity
	
	for my_item : Item in item_array:
		if my_item.current_quantity <= quantity_left_to_remove:
			quantity_left_to_remove -= my_item.current_quantity
			removal_array.append(my_item)
		else:
			my_item.current_quantity -= quantity_left_to_remove
			quantity_left_to_remove = 0
	
	for my_item : Item in removal_array:
		my_item.get_item_holder().remove(my_item)
		my_item.queue_free()
	
	
func remove_quantity_of_item_with_item_id(quantity : int, item_id : String):
	main_storage.remove_quantity_of_item_with_item_id(quantity, item_id)


func remove_item(item: Item):
	main_storage.remove(item)


func has_enough_scrip(price : int):
	return calculate_quantity_of_item_type(Scrip) >= price


func insert_item_array(item_array : Array[Item], storage_only = true):
	for my_item : Item in item_array:
		if can_fit_anywhere(my_item, storage_only):
			insert_anywhere(my_item, storage_only)
		else:
			return false
	return true


func does_item_array_fit(item_array : Array[Item], storage_only = true):
	return main_storage.does_item_array_fit(item_array)


## create_item_array_from_item_and_quantity is a helper function to create
## an array of item objects which contain the given quantity within their max_quantity
## limits using Item instead of packed scene
static func create_item_array_from_item_and_quantity(item: Item, quantity: int) -> Array[Item]:
	return create_item_array_from_packed_scene_and_quantity(Util.get_packed_scene_from_object(item), quantity)


## create_item_array_from_packed_scene_and_quantity is a helper function to create
## an array of item objects which contain the given quantity within their max_quantity
## limits
static func create_item_array_from_packed_scene_and_quantity(item_scene : PackedScene, quantity : int) -> Array[Item]:
	var item_array : Array[Item] = []
	var current_quantity : int = quantity
	
	while current_quantity > 0:
		var new_item : Item = item_scene.instantiate()
		
		var quantity_in_item = min(current_quantity, new_item.max_quantity)
		new_item.current_quantity = quantity_in_item
		
		item_array.append(new_item)
		current_quantity -= quantity_in_item

	return item_array



# ---------- Saving and Loading Functions --------- #



func generate_hotbar_slot_save_array():
	var save_array = []
	for hotbar_slot : HotbarSlot in hot_bar_slots:
		var save_dictionary = hotbar_slot.generate_save_dictionary()
		save_array.append(save_dictionary)
	return save_array


func load_hotbar_slots_from_array(save_array):
	for hotbar_slot : HotbarSlot in hot_bar_slots:
		for entry in save_array:
			if entry.has(hotbar_slot.SLOT_IDX_SAVE_KEY):
				if entry[hotbar_slot.SLOT_IDX_SAVE_KEY] == hotbar_slot.slot_idx:
					hotbar_slot.load_from_dictionary(entry)
					break


func generate_save_dictionary():
	var save_dictionary = {}
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	
	save_dictionary[MAIN_STORAGE_SAVE_KEY] = main_storage.generate_save_dictionary()
	
	save_dictionary[ARMOUR_SLOT_SAVE_KEY] = armour_slot.generate_save_dictionary()
	
	save_dictionary[BACKPACK_SLOT_SAVE_KEY] = backpack_slot.generate_save_dictionary()
	
	save_dictionary[HOTBAR_SLOT_SAVE_KEY] = generate_hotbar_slot_save_array()

	if is_instance_valid(equipped_item):
		save_dictionary[EQUIPPED_ITEM_SAVE_KEY] = [equipped_item.grid_position.x, equipped_item.grid_position.y]
	
	return save_dictionary


func load_from_dictionary(load_dictionary):
	main_storage.load_from_dictionary(load_dictionary[MAIN_STORAGE_SAVE_KEY])

	if ARMOUR_SLOT_SAVE_KEY in load_dictionary:
		armour_slot.load_from_dictionary(load_dictionary[ARMOUR_SLOT_SAVE_KEY])
	
	if BACKPACK_SLOT_SAVE_KEY in load_dictionary:
		backpack_slot.load_from_dictionary(load_dictionary[BACKPACK_SLOT_SAVE_KEY])
	
	if HOTBAR_SLOT_SAVE_KEY in load_dictionary:
		load_hotbar_slots_from_array(load_dictionary[HOTBAR_SLOT_SAVE_KEY])
		
	if EQUIPPED_ITEM_SAVE_KEY in load_dictionary:
		var equipped_item_grid_location = Vector2(-1, -1)
		equipped_item_grid_location.x = load_dictionary[EQUIPPED_ITEM_SAVE_KEY][0]
		equipped_item_grid_location.y = load_dictionary[EQUIPPED_ITEM_SAVE_KEY][1]
		var item_to_equip : Item = main_storage.get_item_at_grid_position(equipped_item_grid_location)
		if item_to_equip:
			equip_item(item_to_equip)
	
	# This function should update the whole inventory
	on_inventory_size_changed()


# ----- Getters and Setters ----- #

func get_player() -> Player:
	return GameMaster.get_player()


func get_rpg_mechanics_master() -> RPGMechanicsMaster:
	return get_player().rpg_mechanics_master
