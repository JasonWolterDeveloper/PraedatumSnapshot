class_name RestoreHealthOverTime extends RestoreOverTime


func apply_periodic_effect(delta : float):
	super(delta)
	
	RPGEventMaster.invoke_heal_event(calculate_restore_amount_for_time(delta), get_character())
	
