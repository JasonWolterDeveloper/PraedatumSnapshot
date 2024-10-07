class_name TriggerInteractableObject extends InteractableObject

@export var trigger_id_to_activate : String


func activate(activator : Character):
	super(activator)
	var trigger : Trigger = TriggerMaster.get_trigger_by_id(trigger_id_to_activate)
	if trigger:
		trigger.activate()
