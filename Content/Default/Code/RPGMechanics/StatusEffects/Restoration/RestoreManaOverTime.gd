class_name RestoreManaOverTime extends RestoreOverTime


func apply_periodic_effect(delta : float):
	super(delta)
	
	# Currently only the player has mana so we do not need to pass the character
	RPGEventMaster.invoke_restore_mana_event(calculate_restore_amount_for_time(delta))
