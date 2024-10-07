extends TriggerInteractableObject

@onready var button_model : PraedatumButtonModel = $PraedatumButtonModel	


func update_aesthetics():
	super()
	update_button_model()


func update_button_model():
	if can_activate(get_player()):
		button_model.show_can_activate()
	elif has_been_activated and not allow_if_activated:
		button_model.show_previously_activated()
	else:
		button_model.show_cannot_activate()


func activate(activator : Character):
	super(activator)
	var trigger : Trigger = TriggerMaster.get_trigger_by_id(trigger_id_to_activate)
	if trigger:
		trigger.activate()
