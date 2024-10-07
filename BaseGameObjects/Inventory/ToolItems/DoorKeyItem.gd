class_name DoorKeyItem extends UtilityItem

@export var key_level : int = 1
## Key Code is a string that is checked by the corresponding
## door object to determine whether or not this key can unlock the door
@export var key_code : String = ""
@export var consume_on_use : bool = false


func use_key_on_door(door : Door):
	door.unlock_door_with_key(self)
	if consume_on_use:
		queue_free()
