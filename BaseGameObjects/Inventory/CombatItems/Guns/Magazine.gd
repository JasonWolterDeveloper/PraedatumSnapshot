class_name Magazine extends QuantityItem

# ----- Save Constants ----- #
const SELECTED_AMMO_SUBTYPE_SAVE_STRING = "selected_ammo_subtype"

@export var ammo_type : AmmoType

## The Default Bullet this gun fires
@export var bullet_scene : PackedScene
## A Mapping of ammo subtypes to alternative bullets
@export var ammo_subtype_to_bullet_scene_mapping : Dictionary = {}

var selected_ammo_subtype : String



# ---------- Assignment and Ready Functions --------- #


func _ready():
	super()
	assign_initial_selected_ammo_type()


func assign_initial_selected_ammo_type() -> void:
	if not selected_ammo_subtype and ammo_type:
		selected_ammo_subtype = ammo_type.get_default_subtype()



# ---------- Other Functions ---------- #


static func magazine_capacity_sort(a : Magazine, b : Magazine):
	if a.max_quantity > b.max_quantity:
		return true
	return false


func refill_from_ammo_item(ammo: AmmoItem):
	var missing_bullet_quantity = max_quantity - current_quantity
	
	if ammo.current_quantity >= missing_bullet_quantity:
		ammo.current_quantity -= missing_bullet_quantity
		current_quantity = max_quantity
	else:
		current_quantity += ammo.current_quantity
		ammo.current_quantity = 0


func needs_refilling():
	return current_quantity < max_quantity


func can_refill_from_inventory(inventory : Inventory):
	var ammo_items = inventory.find_all_items_of_type_in_storage(AmmoItem)
	for my_ammo_item in ammo_items:
		if is_compatible_with_ammo(my_ammo_item) and my_ammo_item.current_quantity > 0:
			return my_ammo_item
	return null


func find_smallest_quantity_compatible_ammo_item(inventory : Inventory) -> AmmoItem:
	var ammo_items = inventory.find_all_items_of_type_in_storage(AmmoItem)
	var compatible_ammo_items = []
	
	var smallest_quantity_ammo_item : AmmoItem = null
	
	for my_ammo_item in ammo_items:
		if is_compatible_with_ammo(my_ammo_item) and my_ammo_item.current_quantity > 0:
			compatible_ammo_items.append(my_ammo_item)
			
	for my_compatible_ammo_item in compatible_ammo_items:
		if smallest_quantity_ammo_item != null:
			if smallest_quantity_ammo_item.current_quantity > my_compatible_ammo_item.current_quantity:
				smallest_quantity_ammo_item = my_compatible_ammo_item
		else:
			smallest_quantity_ammo_item = my_compatible_ammo_item
	return smallest_quantity_ammo_item


func refill_from_inventory(inventory : Inventory):
	var refill_ammo_item = find_smallest_quantity_compatible_ammo_item(inventory) # can_refill_from_inventory(inventory)
	
	while needs_refilling() and refill_ammo_item:
		refill_from_ammo_item(refill_ammo_item)
		refill_ammo_item = find_smallest_quantity_compatible_ammo_item(inventory)


func insert_round_from_ammo_item(ammo: AmmoItem):
	ammo.current_quantity -= 1
	current_quantity += 1


# Insert a given amount of ammunition from the inventory, by default just one
func insert_rounds_from_inventory(inventory : Inventory, rounds : int = 1):
	var round_loads_attempted = 0
	while round_loads_attempted < rounds and needs_refilling():
		round_loads_attempted += 1
		var refill_item =  find_smallest_quantity_compatible_ammo_item(inventory) # can_refill_from_inventory(inventory)
		if refill_item:
			insert_round_from_ammo_item(refill_item)


func is_compatible_with_gun(gun: Gun):
	return ammo_type in gun.compatible_ammo_types


func is_compatible_with_magazine(mag: Magazine):
	return ammo_type == mag.ammo_type


func is_compatible_with_ammo(ammo : AmmoItem):
	return ammo_type.ammo_type == ammo.ammo_type and selected_ammo_subtype == ammo.ammo_sub_type


func generate_bullet():
	if selected_ammo_subtype in ammo_subtype_to_bullet_scene_mapping:
		var new_bullet_scene : PackedScene = ammo_subtype_to_bullet_scene_mapping[selected_ammo_subtype]
		return new_bullet_scene.instantiate()
	else:
		return bullet_scene.instantiate()



# ---------- Saving and Loading Functions ---------- #


func load_from_dictionary(load_dictionary):
	super(load_dictionary)
	
	if load_dictionary.has(SELECTED_AMMO_SUBTYPE_SAVE_STRING):
		selected_ammo_subtype = load_dictionary[SELECTED_AMMO_SUBTYPE_SAVE_STRING]


func generate_save_dictionary():
	var save_dictionary = super()
	
	save_dictionary[SELECTED_AMMO_SUBTYPE_SAVE_STRING] = selected_ammo_subtype
	
	return save_dictionary
