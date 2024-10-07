class_name ForemanCallInState extends State

## A state for characters who have just lost track of their target, either from becoming invalid or from timing out during the pursuit state
@export var timer_link : ForemanCallInTimerLink

func on_entry(phys_delta) -> bool:
	super(phys_delta)
	my_character.aiming_master.look_straight_forward()
	my_character.animation_player.play("call_in_friends")
	
	if timer_link:
		timer_link.timer.wait_time = 20.0
	return true # One-shot routine
