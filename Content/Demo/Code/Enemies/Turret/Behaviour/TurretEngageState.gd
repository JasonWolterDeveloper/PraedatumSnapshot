class_name TurretEngageState extends State

@export var bullet_speed : float = 60.0

# The way the turret leads the target_character right now is, I think, technically
# correct, but it kinda looks bad, and, with spread they might hit you anyway
# even if we dampen it soooo...
@export var lead_dampening : float = 1.0

## Engage a fellow

func on_entry(phys_delta) -> bool:
	super(phys_delta)
	my_character.activate_turret()
	return true # One-shot routine


# Aim at our target_character every physics frame
func on_active(phys_delta) -> bool:
	super(phys_delta)
	if target_character:
		my_character.attempt_aim_turret(predict_target_location())
		my_character.attempt_fire()
	return false # Continuous routine


func calculate_distance_to_target() -> float:
	return my_character.global_position.distance_to(target_character.global_position)


func predict_target_location():
	var distance_to_target : float = calculate_distance_to_target()

	var predicted_target_location = target_character.global_position + (target_character.velocity/lead_dampening) * (distance_to_target / bullet_speed)
	return predicted_target_location
