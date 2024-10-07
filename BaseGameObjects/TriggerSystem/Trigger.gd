class_name Trigger extends Node

@export var trigger_id: String

@export var allow_if_activated : bool = false
var activated = false

@export var display_text_on_activation : bool = false
@export var text_to_display : String = ""
@export var text_display_time : float = 5.1

var effect_list : Array[TriggerEffect] = []

# TODO: Implement this. If the trigger persists, then, once its activated once
# it will immediately be activated again the next time it appears in a level
@export var trigger_persists : bool = false
@export var trigger_save_key : String

## auto activate makes the trigger activate on level start up
@export var auto_activate : bool = false


func _ready():
	TriggerMaster.add_trigger(self)
	populate_effect_list()


func add_to_trigger_master():
	TriggerMaster.add_trigger(self)


func populate_effect_list():
	effect_list.clear()
	for my_child in get_children():
		if my_child is TriggerEffect:
			effect_list.append(my_child)


## init() is called at the start of a level load after all of the ready functions are complete
## a Level object will call this function by calling the corresponding function in the TriggerMaster
func init():
	## If we're persisting this trigger, such as with unlockable shortcuts or quest objectives
	## We need to check if it has been persisted in the PersistentDataTome and, if it has, we activate the
	## trigger whether or not other conditions are met or not
	if trigger_persists:
		if PersistentDataTome.has_data_key(trigger_save_key):
			if PersistentDataTome.get_data_for_key(trigger_save_key):
				activate()
	if auto_activate:
		activate()
	pass


## Calls all of the activation functions of the underlying events
func activate_effects():
	for my_effect : TriggerEffect in effect_list:
		my_effect.activate_effect()


## Called by other objects to activate this trigger. Calls all of the activation functions
## of the underlying events
func activate():
	if not activated or allow_if_activated:
		activate_effects()
		activated = true
		if trigger_persists:
			PersistentDataTome.set_data_for_key(trigger_save_key, true)
		if display_text_on_activation:
			OnScreenMessageMaster.display_message(text_to_display, text_display_time)
