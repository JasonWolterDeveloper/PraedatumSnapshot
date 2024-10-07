class_name SetActivatedInteractableObjectEffect extends TriggerEffect

@export var interactable_object : InteractableObject


func activate_effect():
	super()
	if interactable_object:
		interactable_object.has_been_activated = true
