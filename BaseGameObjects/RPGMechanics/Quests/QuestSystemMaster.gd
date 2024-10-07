## QuestSystemMaster is a global class used to provide additional functionality
## to the quest system that can be accessed globally, such as locating quest
## waypoints by id, etc.
extends Node

const QUESTS_SAVE_KEY = "quests"
const QUEST_SYSTEM_SAVE_KEY = "quest_system"

var currently_tracked_quest : Quest 

var quest_waypoints  : Dictionary = {}
var player_quest_tracker_ui : QuestTracker
var player_quest_compass : QuestCompass
var actively_tracked_quest : Quest

var active_quest_list : Array[Quest] = []
var complete_quest_list : Array[Quest] = []
var quest_dictionary : Dictionary = {}

# ----- Quest Step Completion Check Variables ----- #
const QUEST_UPDATE_INCREMENT = 0.3
var last_checked_idx : int = 0
var time_since_last_check : float = 0


func populate_active_quest_list():
	active_quest_list.clear()
	var quest_list = generate_quest_list()
	for quest : Quest in quest_list:
		if quest.is_active():
			active_quest_list.append(quest)


func populate_quest_dictionary():
	# No clearing necessary due to dict functionality
	for child in get_children():
		if child is Quest:
			quest_dictionary[child.quest_id] = child


func populate_complete_quest_list():
	complete_quest_list.clear()
	var quest_list = generate_quest_list()
	for quest : Quest in quest_list:
		if quest.is_complete:
			complete_quest_list.append(quest)


func update_active_quests(delta : float) -> void:
	if active_quest_list:
		time_since_last_check += delta
		if time_since_last_check > QUEST_UPDATE_INCREMENT:
			if last_checked_idx >= len(active_quest_list):
				last_checked_idx = 0
			active_quest_list[last_checked_idx].update_step_completion_status()
			last_checked_idx += 1


func reset_quest_system_master():
	actively_tracked_quest = null


func assign_quest_tracker_ui(quest_tracker : QuestTracker):
	player_quest_tracker_ui = quest_tracker


func assign_quest_compass(quest_compass : QuestCompass):
	player_quest_compass = quest_compass


func update_quest_tracker():
	if player_quest_tracker_ui:
		player_quest_tracker_ui.update_from_current_quest()


func show_compass_for_current_quest_current_step():
	if actively_tracked_quest:
		var current_quest_step : QuestStep = actively_tracked_quest.get_current_quest_step()
		if current_quest_step:
			show_compass_for_quest_step(actively_tracked_quest.quest_id, current_quest_step.quest_step_id)


func show_compass_for_quest_step(quest_id : String, quest_step_id: String):
	var quest_step : QuestStep = get_quest_step_by_id(quest_id, quest_step_id)
	if quest_step:
		var quest_waypoint : QuestWaypoint = get_quest_waypoint_by_id(quest_step.quest_waypoint_id)
		if player_quest_compass and quest_waypoint:
			player_quest_compass.display_compass_for_waypoint(quest_waypoint)
			return


func add_quest_waypoint(quest_waypoint):
	quest_waypoints[quest_waypoint.id] = quest_waypoint


func get_quest_waypoint_by_id(quest_waypoint_id : String):
	if quest_waypoints.has(quest_waypoint_id):
		return quest_waypoints[quest_waypoint_id]
	return null


func get_quest_by_id(quest_id : String) -> Quest:
	return find_quest_by_id(quest_id)


func get_quest_step_by_id(quest_id : String, quest_step_id : String) -> QuestStep:
	var quest : Quest = get_quest_by_id(quest_id)
	if quest:
		return quest.find_quest_step_by_step_id(quest_step_id)
	return null
	

func is_quest_started(quest_id : String):
	if get_quest_by_id(quest_id) != null:
		return true


func is_quest_complete(quest_id : String):
	var quest : Quest = find_quest_by_id(quest_id)
	if is_instance_valid(quest):
		return quest.is_complete
	return false


func complete_quest_step(quest_id : String, quest_step_id : String):
	var quest_step : QuestStep = get_quest_step_by_id(quest_id, quest_step_id)
	if quest_step:
		quest_step.complete()


func is_quest_step_started(quest_id : String, quest_step_id : String) -> bool:
	var quest_step : QuestStep = get_quest_step_by_id(quest_id, quest_step_id)
	if quest_step:
		return quest_step.check_is_active()
	return false


func is_quest_step_complete(quest_id : String, quest_step_id : String) -> bool:
	var quest_step : QuestStep = get_quest_step_by_id(quest_id, quest_step_id)
	if quest_step:
		return quest_step.check_completed()
	return false


func set_active_quest_id_for_ui(quest_id : String):
	var quest : Quest = find_quest_by_id(quest_id)
	if quest and not quest.is_complete:
		actively_tracked_quest = quest
		player_quest_tracker_ui.setup_from_quest(quest)


func is_tracking_quest_id(quest_id : String):
	if actively_tracked_quest:
		return actively_tracked_quest.quest_id == quest_id
	return false


func track_any_quest_if_tracking_no_quests():
	if not is_instance_valid(actively_tracked_quest):
		for my_quest : Quest in generate_quest_list():
			if not my_quest.is_complete:
				set_active_quest_id_for_ui(my_quest.quest_id)
				break


func _process(delta):
	update_active_quests(delta)
	if Input.is_action_just_pressed("show_quest_compass"):
		show_compass_for_current_quest_current_step()


func start_quest(quest: Quest):
	quest.start() 
	add_quest(quest)
	populate_quest_dictionary()
	populate_active_quest_list()


func add_quest(quest: Quest):
	if not has_quest_id(quest.quest_id):
		Util.force_add_child(self, quest)


func generate_quest_list():
	var quest_list : Array[Quest] = []
	for my_child in get_children():
		if my_child is Quest:
			quest_list.append(my_child)
	return quest_list


func has_quest_id(quest_id):
	return is_instance_valid(find_quest_by_id(quest_id))


func find_quest_by_id(quest_id):
	if quest_dictionary.has(quest_id):
		return quest_dictionary[quest_id]
	return null


func generate_save_dictionary():
	var save_dictionary = {}
	save_dictionary[SaveConstants.SCENE_PATH_SAVE_KEY] = scene_file_path
	
	var quest_list = generate_quest_list()
	var quest_list_saves = []
	
	for quest in quest_list:
		quest_list_saves.append(quest.generate_save_dictionary())
	
	save_dictionary[QUESTS_SAVE_KEY] = quest_list_saves
	
	return save_dictionary


func remove_quest_children():
	actively_tracked_quest = null
	for child in get_children():
		if child is Quest:
			remove_child(child)
			child.queue_free()  # This will mark the node for deletion


func load_from_dictionary(load_dictionary):
	# Clear existing quests
	remove_quest_children()
	quest_dictionary.clear()
	if QUESTS_SAVE_KEY in load_dictionary:
		var quest_list_save_data = load_dictionary[QUESTS_SAVE_KEY]
		for quest_save_data in quest_list_save_data:
			var quest = SaveLoadUtil.load_object_from_object_entry(quest_save_data)
			if quest:
				add_quest(quest)
	populate_quest_dictionary()
	populate_active_quest_list()


# Function to save to persistent data store
func save_to_persistent_data_tome():
	var save_dict = generate_save_dictionary()
	PersistentDataTome.set_data_for_key(QUEST_SYSTEM_SAVE_KEY, save_dict)


# Function to load from persistent data store
func load_from_persistent_data_tome():
	var save_dict = PersistentDataTome.get_data_for_key(QUEST_SYSTEM_SAVE_KEY)
	if save_dict:
		load_from_dictionary(save_dict)
