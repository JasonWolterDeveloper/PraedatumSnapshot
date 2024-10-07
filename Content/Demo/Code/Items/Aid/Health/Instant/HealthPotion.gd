class_name HealthPotionItem extends RestoreOverTimeItem

func can_use_utility():
	if get_wielder():
		if get_wielder().rpg_mechanics_master.health.check_is_full():
			cannot_use_message = "Health Full"
			return false
	return true
