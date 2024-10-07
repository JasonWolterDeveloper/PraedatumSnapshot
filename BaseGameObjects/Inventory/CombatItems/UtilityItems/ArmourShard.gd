class_name ArmourShard extends HoldUseItem

## A simple utility item that refills a non-full armour shard. Only consumed if it can refill


var armour:Armour:
	get: return get_wielder().armour


## @Override
func use_utility():
	if armour:
		var prev_quantity = current_quantity
		current_quantity -= int(armour.refill())
		if prev_quantity != current_quantity:
			play_use_utility_aesthetics()
	else:
		OnScreenMessageMaster.display_message("No Armour")


func can_use_utility():
	if not is_instance_valid(armour):
		cannot_use_message = "No Armour"
		return false
	elif armour.is_full():
		cannot_use_message = "Armour Full"
		return false
	return true
	 


func can_stack_with_item(item : Item):
	if item is ArmourShard:
		return not item.is_full()
	return super(item)
