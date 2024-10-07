extends RPGEvent

class_name RateOfFireEvent

# ----- Parameters ----- #
var weapon: Weapon

# ----- Modifiere ----- #
var rate_of_fire_multiplicative_modifier: float = 0

func invoke_event():
	var modified_time_between_shots = max(0, weapon.time_between_shots * (1.0 - rate_of_fire_multiplicative_modifier))
	var modified_time_between_burst_shots = max(0, weapon.time_between_burst_shots * (1.0 - rate_of_fire_multiplicative_modifier))
	
	weapon.modified_time_between_shots = modified_time_between_shots
	weapon.modified_time_between_burst_shots = modified_time_between_burst_shots
