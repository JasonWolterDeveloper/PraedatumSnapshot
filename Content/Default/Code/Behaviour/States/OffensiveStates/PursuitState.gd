class_name PursuitState extends MoveState

## A state for moving towards an enemy


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	my_character.aiming_master.should_look_in_movement_direction = true
	return true # One-shot routine


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	movement_target = target_last_known_position
	super(phys_delta)
	
	return false # Continuous routine
