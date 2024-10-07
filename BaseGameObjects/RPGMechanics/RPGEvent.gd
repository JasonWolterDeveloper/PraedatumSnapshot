extends Node

class_name RPGEvent

var applied_event_modifiers : Array[RPGEventModifier] = []

func invoke_event():
	queue_free()
	
func add_applied_event_modifer(modifier : RPGEventModifier):
	applied_event_modifiers.append(modifier)
	
func has_applied_event_modifer(modifier : RPGEventModifier):
	return (modifier in applied_event_modifiers)
