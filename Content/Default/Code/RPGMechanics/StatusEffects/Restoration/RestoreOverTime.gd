##Generic Restoration Status Effect. Has no Effect on its own, must use an extension
class_name RestoreOverTime extends RPGStatusEffect

@export var restoration_per_second : float = 1.0
# var origin_character : Character = null 


func calculate_restore_amount_for_time(delta: float):
	return delta * restoration_per_second
