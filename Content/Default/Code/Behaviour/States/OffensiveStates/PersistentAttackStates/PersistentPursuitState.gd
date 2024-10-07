class_name PersistentPursuitState extends PursuitState

## A state for moving towards an enemy

# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	my_character.ai_memory.target_last_known_position = target_character.global_position
	
	return super(phys_delta)
