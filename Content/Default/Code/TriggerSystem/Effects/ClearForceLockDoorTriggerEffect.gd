class_name ClearForceLockTriggerEffect extends TriggerEffect


@export var door : Door


func activate_effect():
	if door:
		door.clear_force_locked()
