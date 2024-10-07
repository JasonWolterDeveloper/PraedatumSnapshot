class_name TurretTargetLostLink extends Link

func is_triggered():
	var no_target_los:bool = target_character and not my_character.check_los_to_character(target_character, 0x3)
	
	my_character.ai_memory.can_see_target = not no_target_los
	return no_target_los 
