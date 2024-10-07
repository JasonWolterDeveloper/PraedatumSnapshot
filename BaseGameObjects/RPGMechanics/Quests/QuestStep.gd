class_name QuestStep extends Node

const IS_COMPLETE_SAVE_KEY = "is_complete"
const QUEST_STEP_ID_SAVE_KEY = "quest_step_id"

var player: Player:
	get: return Util.get_character_parent(self)

var quest : Quest:
	get: return get_quest()
	
@export var should_complete_quest = false

var is_complete = false
var is_active = false

@export var prequisite_steps : Array[QuestStep] = []
@export var success_conditions : Array[ConditionEvaluator] = []
@export var should_uncomplete_if_conditions_not_met : bool = false

@export var quest_step_id = "defaultqueststep"
@export var display_name : String = ""
@export var quest_waypoint_id : String = ""

@export var next_quest_step : QuestStep

signal completed
signal uncompleted


func complete():
	is_complete = true
	emit_signal("completed")
	quest.notify_quest_status_changed()
	
	DebugMaster.log_debug("Successfully Completed Quest Step: \"" + quest_step_id + "\" for Quest: \"" + quest.display_name + "\"")
	
	if should_complete_quest:
		quest.complete()


func uncomplete():
	is_complete = false
	uncompleted.emit()
	quest.notify_quest_status_changed() 
	
	DebugMaster.log_debug("Uncompleted Quest Step: \"" + quest_step_id + "\" for Quest: \"" + quest.display_name + "\"")


func update_completion_status():
	if is_complete:
		if should_uncomplete_if_conditions_not_met and not check_completed():
			uncomplete()  
		return
	else:
		if check_completed():
			complete()


## check_completed() Runs through all condition evaluators to determine if this step is complete.
## if we do not have any condition evaluators, we do not complete ourselves
func check_completed():
	if not success_conditions:
		return false
	else:
		for condition : ConditionEvaluator in success_conditions:
			if not condition.evaluate():
				return false
		return true


func check_is_active():
	if is_complete:
		return false
	for quest_step in prequisite_steps:
		if not quest_step.is_complete:
			return false
	if quest.is_complete:
		return false
	return true


func get_quest():
	if get_parent() == null:
		return null
	elif get_parent() is QuestStep:
		return get_parent().get_quest()
	elif get_parent() is Quest:
		return get_parent()
	return null


func generate_save_dictionary():
	var save_dictionary = {}
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	
	save_dictionary[IS_COMPLETE_SAVE_KEY] = is_complete
	save_dictionary[QUEST_STEP_ID_SAVE_KEY] = quest_step_id
	
	return save_dictionary


func load_from_dictionary(load_dictionary):
	if IS_COMPLETE_SAVE_KEY in load_dictionary:
		is_complete = load_dictionary[IS_COMPLETE_SAVE_KEY]
	
