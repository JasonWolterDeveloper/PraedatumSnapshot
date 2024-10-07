class_name TargetJustLostState extends State

## A state for characters who have just lost track of their target, either from becoming invalid or from timing out during the pursuit state


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	my_character.aiming_master.should_look_in_movement_direction = true
	return true # One-shot routine
