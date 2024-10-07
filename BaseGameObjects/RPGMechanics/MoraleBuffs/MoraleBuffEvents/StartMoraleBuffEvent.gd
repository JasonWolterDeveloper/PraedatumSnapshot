class_name StartMoraleBuffEvent extends RPGEvent

# ----- Parameters ----- #
var morale_buff : MoraleBuff

# ----- Modifiers ----- #
var duration_multiplicative_modifier : float = 1.0
var duration_additive_modifier : float = 0.0


func invoke_event():
	if morale_buff:
		var modified_duration = morale_buff.base_duration * duration_multiplicative_modifier + duration_additive_modifier
		morale_buff.modified_duration = modified_duration
		morale_buff.set_current_duration(modified_duration)
