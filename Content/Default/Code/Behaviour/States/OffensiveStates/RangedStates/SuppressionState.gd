class_name SuppressionState extends RangedAttackState

## A simple extension of RangedAttackState which fires at a location once our 
## character is within range. 


## @Override
## Not to be confused with Enemy.can_attack_target()
func can_attack_target():
	if my_character.can_attack():
		var in_range = my_character.global_position.distance_to(target_last_known_position) < maximum_attack_range
		if in_range:
			var los_to_target:bool = Util.los_collision_point_raycast(my_character.global_position, target_last_known_position).is_equal_approx(target_last_known_position)
			return los_to_target
	return false

   
func attack():
	my_character.aiming_master.aim_point = target_last_known_position
	my_character.attempt_fire()
