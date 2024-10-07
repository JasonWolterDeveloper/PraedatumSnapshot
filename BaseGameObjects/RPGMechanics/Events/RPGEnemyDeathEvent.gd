class_name RPGEnemeyDeathEvent extends RPGEvent

var dying_enemy : Enemy


func invoke_event():
	if dying_enemy != null:
		RPGEventMaster.invoke_experience_event(dying_enemy.awarded_experience_points)
