class_name CloseAndForceLockDoorTrigger extends TriggerEffect


@export var door : Door


func activate_effect():
	if door:
		if door.is_open:
			door.close_door()
		door.force_locked()
