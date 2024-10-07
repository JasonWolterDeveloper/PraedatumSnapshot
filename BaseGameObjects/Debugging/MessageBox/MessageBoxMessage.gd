extends Label

class_name MessageBoxMessage

var time_alive = 0  # How long this message has existed
const MAX_TIME_ALIVE = 10  # The maximum time this message should exist before deletion
#var dynamicFont = null

func _ready():
	set_custom_minimum_size(Vector2(100, 30))

func _process(delta):
		time_alive += delta

func check_should_delete():
	if time_alive > MAX_TIME_ALIVE:
		return true
	return false
