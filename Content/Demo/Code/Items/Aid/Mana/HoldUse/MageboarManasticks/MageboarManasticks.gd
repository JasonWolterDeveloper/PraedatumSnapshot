class_name MageboarManasticks extends HoldUseItem

@export var mana_restore_amount : float = 25


func use_utility():
	apply_to_character(get_wielder())
	super()
	current_quantity -= 1


func can_use_utility():
	if get_wielder():
		if get_wielder().rpg_mechanics_master.mana.check_is_full():
			cannot_use_message = "Mana Full"
			return false
	return true


func alt_use_utility():
	# Does Nothing For Cigarettes
	pass


func apply_to_character(character : Character):
	RPGEventMaster.invoke_restore_mana_event(mana_restore_amount)
