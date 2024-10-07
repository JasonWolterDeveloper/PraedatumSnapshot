class_name ConversationChoice extends Node

@export var unique_id : String = ""
@export var text : String = ""

@export var availability_condition : String = ""
@export var unavailability_condition : String = ""

@export var availability_condition_evaluators : Array[ConditionEvaluator] = []

@export var next_state : ConversationState 

@export var function : String = ""
@export var function_parameters : Array = []

var conversation_choice_state : ConversationChoiceState


func assign_conversation_choice_state(new_conversation_choice_state : ConversationChoiceState):
	conversation_choice_state = new_conversation_choice_state


func is_available():
	var passed_availability_check = false
	if availability_condition.strip_edges() == "":
		passed_availability_check = true
	else:
		if PersistentDataTome.has_data_key(availability_condition):
			passed_availability_check = PersistentDataTome.get_data_for_key(availability_condition)
	
	var passed_unavailability_check = true
	
	if unavailability_condition.strip_edges() != "":
		if PersistentDataTome.has_data_key(unavailability_condition):
			passed_unavailability_check =  not PersistentDataTome.get_data_for_key(unavailability_condition)
	
	for my_condition : ConditionEvaluator in availability_condition_evaluators:
		if not my_condition.evaluate():
			passed_availability_check = false
			break
	
	return passed_availability_check and passed_unavailability_check


func run_conversation_function():
	if function and function.strip_edges() != "":
		ConversationMaster.use_conversation_choice_function(function, function_parameters)


func handle_select():
	conversation_choice_state.handle_select(self)
	run_conversation_function()
	
	
