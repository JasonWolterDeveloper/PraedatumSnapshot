extends ItemHolder

class_name LoadoutSlot

@export var item_type : Item.item_types

const ITEM_SAVE_KEY = "item"

func has_item():
	return get_item() != null


func get_item():
	for my_child in get_children():
		if my_child is Item:
			return my_child


func clear():
	if has_item():
		get_item().queue_free()


func can_fit(new_item, pos, collide_self=false):
	return can_fit_anywhere(new_item)


func can_fit_anywhere(new_item, collide_self=false):
	if not has_item():
		if new_item.item_type == item_type:
			return true
	return false


func insert(item_to_be_inserted : Item, insert_position):
	# Default Loadout slots only have one gridsquare for one item, so we always insert them to (0, 0)
	super(item_to_be_inserted, Vector2(0, 0))


func can_interact(item : Item, item_position : Vector2):
	var overlap_item = get_item()
	
	if overlap_item:
		if item.can_interact_with_item(overlap_item):
			return overlap_item
	return false


func load_from_dictionary(load_dictionary):
	if load_dictionary[ITEM_SAVE_KEY] != null:
		load_item_from_item_entry(load_dictionary[ITEM_SAVE_KEY])

	
func generate_save_dictionary():
	var save_dictionary = super()
	if not has_item():
		save_dictionary[ITEM_SAVE_KEY] = null
	else:
		save_dictionary[ITEM_SAVE_KEY] = get_item().generate_save_dictionary()
	
	return save_dictionary
