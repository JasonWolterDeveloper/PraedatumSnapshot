class_name Bandage extends HoldUseItem

@export var heal_amount : float = 25


func use_utility():
	apply_to_character(get_wielder())
	super()
	current_quantity -= 1


func can_use_utility():
	if get_wielder():
		if get_wielder().rpg_mechanics_master.health.check_is_full():
			cannot_use_message = "Health Full"
			return false
	return true  


func alt_use_utility():
	# Does Nothing For Bandage
	pass


func apply_to_character(character : Character):
	RPGEventMaster.invoke_heal_event(heal_amount, character)
