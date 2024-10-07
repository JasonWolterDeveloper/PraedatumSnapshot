class_name ActivateAITriggerEffect extends TriggerEffect


@export var ai_to_activate : Enemy


func activate_effect():
	if ai_to_activate:
		ai_to_activate.enable_ai()
