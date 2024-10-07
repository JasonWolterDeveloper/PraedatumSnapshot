class_name TurretSuppressionState extends State


## Engage a fellow\
func on_entry(phys_delta) -> bool:
	super(phys_delta)
	return true # One-shot routine


# Aim at our target every physics frame
func on_active(phys_delta) -> bool:
	super(phys_delta)
	var last_known_position = get_target_last_known_position()
	if last_known_position != null:
		my_character.attempt_aim_turret(last_known_position)
		my_character.attempt_fire()
	return false # Continuous routine


func get_target_last_known_position():
	if my_character.ai_memory:
		if my_character.ai_memory.target_last_known_position != null:
			return my_character.ai_memory.target_last_known_position
	return null
