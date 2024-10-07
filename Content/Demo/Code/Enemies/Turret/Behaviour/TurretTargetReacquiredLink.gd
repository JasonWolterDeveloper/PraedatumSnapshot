class_name TurretTargetReaquiredLink extends Link

func is_triggered():
	return target_character and my_character.check_los_to_character(target_character, 0x3)
