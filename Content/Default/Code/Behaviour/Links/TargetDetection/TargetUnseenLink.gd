extends TargetSeenLink


func is_triggered() -> bool:
	var seen:bool = super()
	
	if not seen:
		my_character.ai_memory.can_see_target = false
	return seen
