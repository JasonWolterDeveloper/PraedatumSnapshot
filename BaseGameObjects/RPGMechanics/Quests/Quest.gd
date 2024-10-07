class_name Quest extends Node

const QUEST_STEPS_SAVE_KEY = "quest_steps"
const QUEST_COMPLETE_SAVE_KEY = "is_complete"
const QUEST_ACTIVE_SAVE_KEY = "active"
const QUEST_STEP_ID_SAVE_KEY = "quest_step_id"
signal quest_step_list_changed
signal quest_status_changed

var player : Player:
	get: return Util.get_character_parent(self)
	
var rpg_mechanics_master: RPGMechanicsMaster:
	get: 
		if player: 
			return player.rpg_mechanics_master
		else:
			return null
	

## quest_reward is a Node3D that contains a number of items that serve as a
## reward for this quest
var quest_reward : Node3D
var quest_reward_array : Array[Item]

# ------ Completion and Activation Vars ----- #
var active = false
var is_complete = false
@export var can_complete_if_all_steps_complete : bool = false
@export var completion_condition_evaluators : Array[ConditionEvaluator] = []
@export var availability_conditions : Array[ConditionEvaluator] = []

# ----- Export Vars ----- #
@export var display_name = "A Great Quest"
@export var quest_id = "defaultquest"
@export_multiline var quest_description = ""

@export var should_award_experience = true
@export var expierence_reward = 0

"""
## Initial Quest Step ID is the id first active quest step for this quest.
## We will use IDs purely to track which quest is active
@export var initial_quest_step_id : String
var active_quest_step_id : String
"""

var step_list : Array[QuestStep] = []


func _ready():
	quest_reward = Util.find_node_by_name(self, "QuestReward")
	populate_quest_step_list()
	populate_quest_reward_list()


func start():
	active = true


func complete():
	DebugMaster.log_debug("Successfully Completed Quest: \"" + display_name + "\"")
	is_complete = true
	if should_award_experience:
		RPGEventMaster.invoke_experience_event(expierence_reward)
	give_quest_reward()
	active = false
	notify_quest_status_changed()


func check_all_steps_complete():
	for quest_step : QuestStep in step_list:
		if not quest_step.is_complete:
			return false
	return true


func can_complete():
	if can_complete_if_all_steps_complete:
		return check_all_steps_complete()
	else:
		for condition : ConditionEvaluator in completion_condition_evaluators:
			if not condition.evaluate():
				return false
		return true


func is_available():
	for condition : ConditionEvaluator in availability_conditions:
		if not condition.evaluate():
			return false
	return true


func is_active():
	return active

	
func give_quest_reward():
	for my_item : Item in quest_reward_array:
		InventoryMaster.add_item_inventory_and_stash_and_lost_and_found_overflow(my_item)


func populate_quest_step_list():
	step_list.clear()
	for my_child in get_children():
		if my_child is QuestStep:
			step_list.append(my_child)
	return step_list


func populate_quest_reward_list():
	quest_reward_array.clear()
	if quest_reward:
		for my_child in quest_reward.get_children():
			if my_child is Item:
				quest_reward_array.append(my_child) 


func get_current_quest_step():
	for quest_step : QuestStep in step_list:
		if not quest_step.is_complete:
			return quest_step


func find_quest_step_by_step_id(step_id):
	for quest_step in step_list:
		if quest_step.quest_step_id == step_id:
			return quest_step
			
	return null


func update_step_completion_status():
	if is_active():
		for quest_step : QuestStep in step_list:
			quest_step.update_completion_status() 


func generate_save_dictionary():
	var save_dictionary = {}
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	
	save_dictionary[QUEST_COMPLETE_SAVE_KEY] = is_complete
	
	save_dictionary[QUEST_ACTIVE_SAVE_KEY] = active
	var quest_step_list_saves = []
	
	for quest in step_list:
		quest_step_list_saves.append(quest.generate_save_dictionary())
	
	save_dictionary[QUEST_STEPS_SAVE_KEY] = quest_step_list_saves
	
	return save_dictionary


func load_from_dictionary(load_dictionary):
	if QUEST_COMPLETE_SAVE_KEY in load_dictionary:
		is_complete = load_dictionary[QUEST_COMPLETE_SAVE_KEY]
		
	if QUEST_ACTIVE_SAVE_KEY in load_dictionary:
		active = load_dictionary[QUEST_ACTIVE_SAVE_KEY]
	
	if QUEST_STEPS_SAVE_KEY in load_dictionary:
		# We unfortunately need to populate the step list here because ready
		# hasn't been called yet, oop
		populate_quest_step_list()
		var quest_step_list_save_data = load_dictionary[QUEST_STEPS_SAVE_KEY]
		for quest_step_save_data in quest_step_list_save_data:
			for quest_step in step_list:
				# TODO - Consider using UIDs or DisplayNames to identify individual save entries
				# instead of scene paths in the future. Scene Paths could change during development
				# and break saves
				if quest_step.quest_step_id == quest_step_save_data[QUEST_STEP_ID_SAVE_KEY]:
					quest_step.load_from_dictionary(quest_step_save_data)
					
	emit_signal("quest_step_list_changed")


func notify_quest_status_changed():
	emit_signal("quest_status_changed")
	QuestSystemMaster.update_quest_tracker()

## Used to interface with NPC Quest Lists and the Hub quest menu
## The player needs to keep track of their quest status in the QuestSystemMaster
## but NPCs need access to all relevant quests to themselves. So, when we start
## a quest we copy it and add it to the QuestSystemMaster
func start_copy_of_quest():
	var object_scene : PackedScene = load(scene_file_path)
	if object_scene:
		var quest_copy : Quest = object_scene.instantiate()
		QuestSystemMaster.start_quest(quest_copy)
		
