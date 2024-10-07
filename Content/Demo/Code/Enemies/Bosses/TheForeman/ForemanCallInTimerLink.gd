class_name ForemanCallInTimerLink extends TimeoutLink


func is_triggered():
	# var foreman : Foreman = my_character as Foreman
	return timer_expired() # foreman.current_number_of_call_ins < foreman.max_number_of_call_ins and timer_expired()
