class_name PersistentMeleeAttackState extends MeleeAttackState


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	my_character.ai_memory.target_last_known_position = target_character.global_position
	super(phys_delta)
	
	return false # Continuous Routine
