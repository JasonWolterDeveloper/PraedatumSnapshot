class_name ManaPotionItem extends RestoreOverTimeItem

func can_use_utility():
	if get_wielder():
		if get_wielder().rpg_mechanics_master.mana.check_is_full():
			cannot_use_message = "Mana Full"
			return false
	return true
