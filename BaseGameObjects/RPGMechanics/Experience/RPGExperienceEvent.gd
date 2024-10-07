class_name RPGExperienceEvent extends RPGEvent

# ----- Parameters ----- #
var experience_gained : int = 1

# ----- Modifiers ----- #
var experience_multiplicative_modifier : float = 1.0

func invoke_event():
	var warrior : Warrior = WarriorMaster.get_selected_warrior()
	
	var modified_experience_gain = experience_gained * experience_multiplicative_modifier 
	warrior.gain_experience(modified_experience_gain)
	DebugMaster.log_debug("Gained : " + str(modified_experience_gain) + " Experience")
	DebugMaster.log_debug("We now have: " + str(warrior.current_experience_points))
	super()
