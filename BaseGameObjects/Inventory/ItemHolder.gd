extends InventoryObject

class_name ItemHolder


# ----- Signals ----- #
## Changed is a signal to indicate that this ItemHolder has changed in some way, either grown in size
## or changed what it is holding. This is primarily used by the inventory to check if its sub itemHolders
## have changed
signal changed



# ---------- Item Management ---------- #

# Transfers an item in this ItemHolder to another ItemHolder
func transfer(item_to_be_transfered : Item, new_item_holder : ItemHolder, transfer_position):
	remove_child(item_to_be_transfered)
	new_item_holder.insert(item_to_be_transfered, transfer_position)
	changed.emit()


func insert(item_to_be_inserted : Item, insert_position : Vector2):
	item_to_be_inserted.grid_position = insert_position
	Util.force_add_child(self, item_to_be_inserted)
	changed.emit()


func insert_anywhere(item_to_be_inserted : Item):
	insert(item_to_be_inserted, Vector2(0, 0))
	

func remove(item_to_be_removed : Item):
	remove_child(item_to_be_removed)
	changed.emit()


func can_fit(new_item, pos, collide_self=false):
	return false


func can_fit_anywhere(new_item, collide_self=false):
	return false


# Deletes all contained items`
func clear():
	return


# Replaces one item with another in the item_holder. The item to be replaced and
# the replacement item must be the same width and height for this to work properly
# but this function currently does not check for this
func replace(item_to_replace : Item, new_item: Item):
	var grid_position = item_to_replace.grid_position
	
	remove(item_to_replace)
	insert(new_item, grid_position)


## Used by other classes to notify this item holder that it has been forcibly changed
func notify_changed():
	changed.emit()


func can_interact(item: Item, grid_square : Vector2):
	return false


func has_given_item(item : Item):
	# NOTE This method is a bit cringe but I think it should work
	for my_child in get_children():
		if my_child == item:
			return true
	return false



# ---------- Saving and Loading Functions ----------- #


func load_item_from_item_entry(item_entry):
	var new_item = SaveLoadUtil.load_object_from_object_entry(item_entry)
	if new_item:
		Util.force_add_child(self, new_item)



# ---------- Getters and Setters ---------- #


func get_item_at_grid_position(grid_position : Vector2) -> Item:
	for child in get_children():
		if child is Item:
			if child.grid_position == grid_position:
				return child
	return null
