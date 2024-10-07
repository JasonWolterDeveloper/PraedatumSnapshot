class_name UtilityItem extends QuantityItem

## utility_item_use_message is a message to be displayed when this utility
## item is used. If it is an empty string, no message will be displayed
@export var utility_item_use_message : String = ""
@export var cannot_use_message : String = ""

## utility_item_use_message is a message to be displayed when this utility
## item is used with alternate fire. If it is an empty string, no message will 
## be displayed
@export var utility_item_alt_use_message : String = "" 
@export var cannot_alt_use_message : String = ""


func use_utility():
	play_use_utility_aesthetics()


func play_use_utility_aesthetics():
	OnScreenMessageMaster.display_message(utility_item_use_message)


func alt_use_utility():
	play_alt_use_utility_aesthetics()


func play_alt_use_utility_aesthetics():
	OnScreenMessageMaster.display_message(utility_item_alt_use_message)


func show_cannot_use_message():
	OnScreenMessageMaster.display_message(cannot_use_message)


func show_cannot_alt_use_message():
	OnScreenMessageMaster.display_message(cannot_alt_use_message)


func get_wielder():
	return Util.get_character_parent(self)



# ---------- Can Use Functions ----------- #


func can_use_utility() -> bool:
	return true
	

func can_alt_use_utility() -> bool:
	return true



# --------- Equipped Item Use Functions --------- #


func on_use_item_pressed():
	super()
	if can_use_utility():
		use_utility()
	else:
		show_cannot_use_message()


func on_use_item_released():
	super()


func on_alt_use_item_pressed():
	super()
	if can_alt_use_utility():
		alt_use_utility()
	else:
		show_cannot_alt_use_message()


func on_alt_use_item_released():
	super()


func use_from_inventory():
	use_utility()


func can_use_from_inventory():
	#if is_hold_to_use:
	#   return GameMaster.get_level().is_hub_level and super()
	#else:
	return super()
