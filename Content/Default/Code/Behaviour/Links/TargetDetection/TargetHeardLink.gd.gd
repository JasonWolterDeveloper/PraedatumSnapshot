class_name TargetHeardLink extends Link

func is_triggered() -> bool:
	var heard_target:bool = my_character.ai_memory.target_just_heard
		
	if heard_target: 
		my_character.ai_memory.target_just_heard = false
	return heard_target
