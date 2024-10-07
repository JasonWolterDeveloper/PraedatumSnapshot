class_name FirstAidPerk extends RPGPerk

@export var time_until_heal = 5
@export var heal_amount_per_second = 10

var time_since_last_harm = 0
var health_at_last_check = -1


func _process(delta):
	if should_heal():
		var current_health = character.rpg_mechanics_master.health.value
		time_since_last_harm += delta
		
		if current_health < health_at_last_check:
			time_since_last_harm = 0
			
		else:
			if time_since_last_harm > time_until_heal:
				heal(delta)
				
		health_at_last_check = current_health


func heal(delta : float):
	## TODO - Change this so that it uses the new segments functionality lol
	var maximum_heal_value = calculate_closest_quarter_above_current_health()
	var heal_value = delta * heal_amount_per_second
	
	var new_health_value = min(character.rpg_mechanics_master.health.value + heal_value, maximum_heal_value)
	DebugMaster.log_debug("Healed to: " + str(new_health_value))
	character.rpg_mechanics_master.health.value = new_health_value
	

func should_heal():
	return character.rpg_mechanics_master.health.value != calculate_closest_quarter_above_current_health()
	
	
func calculate_closest_quarter_above_current_health():
	var quarter_increment = character.rpg_mechanics_master.max_health.value / 4.0
	var closest_quarter_above_health = ceil(character.rpg_mechanics_master.health.value / quarter_increment) * quarter_increment

	return closest_quarter_above_health
