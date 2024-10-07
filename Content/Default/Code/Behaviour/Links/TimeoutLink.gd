class_name TimeoutLink extends Link

@export var duration:float = 1.0 # [sec]


func on_entry():
	super()
	timer.wait_time = duration


func is_triggered():
	return timer_expired()
