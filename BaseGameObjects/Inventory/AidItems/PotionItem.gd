class_name PotionItem extends UtilityItem


func apply_to_character(character : Character):
	pass
	

func use_on_self():
	apply_to_character(item_owner)
  
  
func use_utility():
	super()
	use_on_self()
	current_quantity -= 1


# returns the PackedScene for the combined potion item that will result when combining this
# potion with the given potion. Will return null if the potions cannot be combined
func find_combined_potion_scene(potion : PotionItem) -> PackedScene:
	return null


# If this potion and the given potion can be combined, 
# deletes both this and the other potion and replaces this potion
# in its inventory slot with the resulting combined potion
func combine_potion(potion : PotionItem):
	var combined_potion_scene : PackedScene = find_combined_potion_scene(potion)
	
	if combined_potion_scene:
		var new_potion_item = combined_potion_scene.instantiate()
		get_item_holder().replace(self, new_potion_item)
		
		# TODO - Currently we need this implementation because the UI won't detect that the potion
		# Has been queued to be free, so, we need to explicitly remove it from its parent item holder
		# if we want it to disappear from the UI on time
		if potion.get_parent():
			potion.get_parent().remove_child(potion)
		potion.queue_free()
		queue_free()
		
		return true
	return false
   
   
func interact_with_item(item : Item) -> bool:
	""" NOTE - Potion Combining Removed for now
	if item is PotionItem:
		return item.combine_potion(self)
	"""
	return super(item)
   
	 
func can_interact_with_item(item : Item):
	""" NOTE - Potion Combining Removed for now
	if item is PotionItem:
		return find_combined_potion_scene(item) != null
	"""
	return super(item)
