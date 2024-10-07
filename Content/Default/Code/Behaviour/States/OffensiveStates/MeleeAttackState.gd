class_name MeleeAttackState extends MoveState

## A state for moving toward the player and melee attacking them at the same time

var time_between_attacks:float = 0.5 # [s]
var time_since_last_attack:float # [s]
var started_attacking := false
var attack_damage


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	var attack_rate = my_character.rpg_mechanics_master.melee_rate
	attack_damage = my_character.rpg_mechanics_master.melee_damage

	if my_character is NanomachineHive:
		my_character.activate_nanomachines()
	
	if attack_rate:
		time_between_attacks = attack_rate.value ** -1 # attack/s -> s/attack
	return true # One-shot routine


# Pathfind towards our target every physics frame
func on_active(phys_delta) -> bool:
	movement_target = target_last_known_position
	super(phys_delta)
	
	if my_character.can_attack() and my_character.can_attack_target(target_character):
		if not started_attacking: # Begin attacking
			time_since_last_attack = 0
			attack()
		else: # Continue attacking
			time_since_last_attack += phys_delta
			if time_between_attacks > 0:
				if time_since_last_attack > time_between_attacks:
					attack()

	return false # Continuous routine


func on_exit(phys_delta) -> bool:
	super(phys_delta)
	started_attacking = false
	return true # One-shot routine


func attack():
	assert(my_character and target_character)
	if target_character:
		started_attacking = true
		time_since_last_attack = 0
		my_character.attack_target(target_character)
