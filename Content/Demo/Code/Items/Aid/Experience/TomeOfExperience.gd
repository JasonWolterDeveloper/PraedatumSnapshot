class_name ExperienceGainTome extends UtilityItem

# Variable indicating how much experience this item awards
@export var experience_amount : float = 1000.0

# Called when the item is used
func use_utility():
	# Invoke the experience event in the RPGEventMaster singleton
	RPGEventMaster.invoke_experience_event(experience_amount)
	
	# Decrement the current quantity variable by one
	current_quantity -= 1
