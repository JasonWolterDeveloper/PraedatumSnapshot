class_name QuantityItem extends Item


const CURRENT_QUANTITY_SAVE_KEY = "current_quantity"


func calculate_missing_quantity():
	return max_quantity - current_quantity


func is_full():
	return current_quantity >= max_quantity


func can_interact_with_item(item: Item):
	if can_stack_with_item(item):
		return true
	return super(item)


func interact_with_item(item: Item) -> bool:
	if can_stack_with_item(item):
		return stack(item)
	return super(item)


func generate_pickup_message():
	if show_quantity_in_ui:
		return super() + " x " + str(current_quantity)
	return super()


# --------- Stacking Functions ---------- #


func can_stack_with_item(item : Item):
	if item is QuantityItem:
		var is_same_item_type = (item_id == item.item_id)
		return is_same_item_type and not item.is_full()
	return super(item)



# ---------- Save Load Functions ---------- #


func load_from_dictionary(load_dictionary):
	super(load_dictionary)
	
	current_quantity = load_dictionary[CURRENT_QUANTITY_SAVE_KEY]


func generate_save_dictionary():
	var save_dictionary = super()
	
	save_dictionary[CURRENT_QUANTITY_SAVE_KEY] = current_quantity
	
	return save_dictionary
