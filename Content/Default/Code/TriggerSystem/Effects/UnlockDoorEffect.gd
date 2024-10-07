class_name UnlockDoorEffect extends TriggerEffect

@export var door : Door


func activate_effect():
	super()
	if door:
		door.unlock_door()
