extends InteractableObject

class_name LevelTransitionInteractable

## the file path to the level we want to transition to. Can be null
## if this is an extraction point but is required otherwise
@export_file("*.tscn") var destination_level : String
@export var is_extraction_point : bool = false

func activate(activator):
	super(activator)
	if is_extraction_point:
		get_level().handle_successful_extraction()
	else:
		get_level().change_level(destination_level)
