class_name LevelTransitionTriggerEffect extends TriggerEffect

@export_file("*.tscn") var destination_level : String


func activate_effect():
	super()
	Util.get_level(self).change_level(destination_level)
