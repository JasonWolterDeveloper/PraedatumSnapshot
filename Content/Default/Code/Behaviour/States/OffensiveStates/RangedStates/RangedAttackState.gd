class_name RangedAttackState extends MoveState


@export var attack_delay:float = 1.5 ## Don't shoot immediately upon entering this state
var current_attack_delay:float
var use_attack_delay:bool:
	get:
		return my_character.ai_memory.use_attack_state_delay

@export var bullet_speed : float = 60.0

# The way the turret leads the target right now is, I think, technically
# correct, but it kinda looks bad, and, with spread they might hit you anyway
# even if we dampen it soooo...
@export var lead_dampening : float = 1.0

## Range at which enemies begin firing
@export var maximum_attack_range : float = 10.0
## Ranged enemies with this behaviour will approach the target until they reach this range, but they will start firing at max attack range
@export var desired_attack_range : float = 8.0


func on_entry(phys_delta) -> bool:
	assert(my_character is RangedEnemy)
	super(phys_delta)
	#my_character.aiming_master.should_look_in_movement_direction = false
	visiting_point_tolerance = desired_attack_range
	current_attack_delay = attack_delay
	
	return true # One-shot routine


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	movement_target = target_last_known_position
	super(phys_delta)
	
	my_character.aiming_master.aim_point = predict_target_location()
	if can_attack_target():
		my_character.attempt_fire()
		my_character.aiming_master.should_look_in_movement_direction = false
	else:
		my_character.aiming_master.should_look_in_movement_direction = true
	current_attack_delay -= phys_delta
	return false # Continuous routine


## Not to be confused with Enemy.can_attack_target()
func can_attack_target() -> bool:
	var done_delay:bool = current_attack_delay <= 0 if use_attack_delay else true
	var in_range = my_character.global_position.distance_to(target_last_known_position) < maximum_attack_range
	return done_delay and in_range and my_character.can_attack() and my_character.can_attack_target(target_character)
	


func calculate_distance_to_target() -> float:
	return my_character.global_position.distance_to(target_last_known_position)


func predict_target_location():
	var distance_to_target : float = calculate_distance_to_target()

	var predicted_target_location = target_last_known_position + (target_character.velocity/lead_dampening) * (distance_to_target / bullet_speed)
	return predicted_target_location
