extends MoraleBuff

@export var heal_per_second : float = 5.0


# Update function that takes delta and runs both update_duration and check_expiry
func update(delta: float) -> void:
	super(delta)
	
	var healed_amount = heal_per_second * delta
	var character : Character = morale_buff_master.player
	
	RPGEventMaster.invoke_heal_event(healed_amount, character)
