class_name OpenDoorTriggerEffect extends TriggerEffect


@export var door : Door


func activate_effect():
	if door:
		if not door.is_open:
			door.open_door()
