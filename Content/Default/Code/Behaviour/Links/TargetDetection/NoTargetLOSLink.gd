class_name NoTargetLOSLink extends Link


func is_triggered():
	var los:bool = my_character.check_los_to_character()
	
	if not los:
		can_see_target = false
		return true
	return false
