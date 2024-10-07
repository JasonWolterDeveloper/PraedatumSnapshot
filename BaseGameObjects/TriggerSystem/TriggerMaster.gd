## TriggerMaster is a Global Class that manages all of the triggers on a particular map
## Triggers are essentially used to handle specialized situations on maps that aren't
## Coded as part of any normal game system. This is for things like storyline events or even
## things like jump scares from a deactivated wage cage 

extends Node

# var trigger_list : Array[Trigger] = []
var trigger_dictionary : Dictionary = {}


func reset_variables():
	trigger_dictionary.clear()


## add_trigger(Trigger) takes a trigger and adds it to the dictionary
## this should typically be called by the trigger itself
func add_trigger(trigger : Trigger):
	trigger_dictionary[trigger.trigger_id] = trigger


func get_trigger_by_id(trigger_id : String):
	return trigger_dictionary[trigger_id]
	

func clear_triggers():
	trigger_dictionary.clear()


func init_triggers():
	for key in trigger_dictionary.keys():
		var trigger : Trigger = trigger_dictionary[key]
		trigger.init()
