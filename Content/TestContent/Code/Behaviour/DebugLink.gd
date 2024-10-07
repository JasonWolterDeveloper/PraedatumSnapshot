extends Link

@export var trigger_on_key:Key

func is_triggered() -> bool:
	return Input.is_physical_key_pressed(trigger_on_key)
