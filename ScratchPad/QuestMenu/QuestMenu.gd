class_name QuestMenu extends Control

# ----- Consts ----- #
const QUEST_TRACKED_PREFIX = "* "
const QUEST_ACTIVE_SUFFIX = " - Active"

# ----- Exports ----- #
@export var quest_step_control : PackedScene
@export var quest_reward_item_control : PackedScene
@export var build_quest_list : Node
@export var build_from_active_quests : bool = false
@export var closable : bool = true
@export var allow_quest_completion : bool = true
@export var allow_quest_acceptance : bool = true

# ----- Model Vars ----- #
var currently_selected_quest : Quest = null
# We track what quests are available in QuestLists, but we track the progress of the
# quest in the QuestSystemMaster. Therefore, the currently_selected_quest is always the
# quest in the QuestList, but the quest we want to populate our details from might be the quest
# in the QuestSystemMaster if its been accepted, or the one in the QuestList if it hasn't, hence
# this variable
var quest_to_get_details_from : Quest = null
var quest_list : Array[Quest] = []

# ----- Control Refs ----- #
var quest_list_control : ItemList
var quest_name_label : Label
var quest_description_label : RichTextLabel
var quest_steps_container : Container

# Buttons
var accept_button : Button
var complete_button : Button
var track_button : Button
var close_button : Button

var quest_details_container : Container
var no_quest_selected_container : Container
var quest_reward_container : Container

# ----- Tracking Vars ----- #
var quest_to_control_mapping : Dictionary = {}
var quest_reward_controls : Array[QuestItemRewardControl] = []



# ---------- Ready and Assignment Functions ---------- #


func _ready() -> void:
	quest_list_control = Util.find_node_by_name(self, "QuestListControl")
	quest_name_label = Util.find_node_by_name(self, "QuestNameLabel")
	quest_description_label = Util.find_node_by_name(self, "QuestDescriptionLabel")
	quest_details_container = Util.find_node_by_name(self, "QuestDetailsContainer")
	no_quest_selected_container = Util.find_node_by_name(self, "NoQuestSelectedContainer")
	quest_steps_container = Util.find_node_by_name(self, "QuestStepsContainer")
	quest_reward_container = Util.find_node_by_name(self, "QuestRewardContainer")
	
	accept_button = Util.find_node_by_name(self, "AcceptButton")
	complete_button = Util.find_node_by_name(self, "CompleteButton")
	track_button = Util.find_node_by_name(self, "TrackButton")
	close_button = Util.find_node_by_name(self, "CloseButton")
	
	if not closable:
		close_button.hide()
	
	populate_quest_list()
	update_quest_details()


func populate_quest_list():
	if build_from_active_quests:
		populate_quests_from_active_quests()
	elif build_quest_list:
		populate_quests_from_quest_list(build_quest_list)
	populate_quest_list_control()


func populate_quests_from_quest_list(given_quest_list : Node):
	quest_list.clear()
	for child in given_quest_list.get_children():
		if child is Quest:
			quest_list.append(child)


func populate_quests_from_active_quests():
	quest_list.clear()
	for quest: Quest in QuestSystemMaster.active_quest_list:
			quest_list.append(quest)


func populate_quest_list_control(): 
	quest_list_control.clear()
	quest_to_control_mapping.clear()
	for quest : Quest in quest_list:
		if should_show_quest(quest):
			var quest_idx = quest_list_control.add_item(construct_quest_list_string(quest))
			quest_to_control_mapping[quest_idx] = quest
			quest_list_control.set_item_custom_fg_color(quest_idx, construct_quest_list_text_colour(quest))


func construct_quest_list_string(quest: Quest) -> String:
	var quest_to_build_for : Quest = quest
	var player_quest =  QuestSystemMaster.find_quest_by_id(quest.quest_id)
	if player_quest:
		quest_to_build_for = player_quest
	var quest_string : String = quest_to_build_for.display_name
	
	if QuestSystemMaster.is_tracking_quest_id(quest_to_build_for.quest_id):
		quest_string = QUEST_TRACKED_PREFIX + quest_string
	if quest_to_build_for.is_active():
		quest_string += QUEST_ACTIVE_SUFFIX

	return quest_string


func construct_quest_list_text_colour(quest : Quest) -> Color:
	var quest_to_build_for : Quest = quest
	var player_quest =  QuestSystemMaster.find_quest_by_id(quest.quest_id)
	if player_quest:
		quest_to_build_for = player_quest
	var quest_color : Color = Color.WHITE_SMOKE
	
	if quest_to_build_for.is_active():
		quest_color = Color.CADET_BLUE
	if QuestSystemMaster.is_tracking_quest_id(quest_to_build_for.quest_id):
		quest_color = Color.CHARTREUSE

	return quest_color


func should_show_quest(quest : Quest):
	if quest.is_available():
		var player_quest = QuestSystemMaster.find_quest_by_id(quest.quest_id)
		if player_quest:
			return not player_quest.is_complete
		return true
	return false



# -------- Update Functions --------- #


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and closable:
		close_quest_menu()


func close_quest_menu():
	hide()


func on_select_quest(quest : Quest):
	currently_selected_quest = quest
	
	quest_to_get_details_from = currently_selected_quest
	var player_quest = QuestSystemMaster.find_quest_by_id(currently_selected_quest.quest_id)
	if player_quest:
		quest_to_get_details_from = player_quest
	
	update_quest_details()


func deselect_quest():
	currently_selected_quest = null
	quest_to_get_details_from = null
	
	update_quest_details()


func update_quest_details():
	if is_instance_valid(quest_to_get_details_from):
		quest_details_container.show()
		no_quest_selected_container.hide()
		
		if quest_name_label:
			quest_name_label.text = quest_to_get_details_from.display_name
		if quest_description_label:
			quest_description_label.text = quest_to_get_details_from.quest_description
		populate_quest_steps()
		populate_quest_rewards()
		
		update_accept_button()
		update_complete_button()
		update_track_button()
	else:
		quest_details_container.hide()
		no_quest_selected_container.show()


func update():
	update_quest_details()
	populate_quest_list()


func reset_quest_vbox():
	var children_to_remove = []
	for my_child in quest_steps_container.get_children():
		if my_child is QuestStepUIEntry:
			children_to_remove.append(my_child)
	for my_child in children_to_remove:
		quest_steps_container.remove_child(my_child)
		my_child.queue_free()


func populate_quest_steps():
	if is_instance_valid(quest_to_get_details_from) and quest_steps_container:
		reset_quest_vbox()
		for my_quest_step in quest_to_get_details_from.step_list:
			var new_quest_step_ui : QuestStepUIEntry = quest_step_control.instantiate()
			
			quest_steps_container.add_child(new_quest_step_ui)
			new_quest_step_ui.build_from_quest_step(my_quest_step)


func find_existing_reward_control_with_same_item_id(item : Item) -> QuestItemRewardControl:
	for reward_control in quest_reward_controls:
		if reward_control.get_item_id() == item.item_id:
			return reward_control
	return null


func populate_quest_rewards():
	Util.delete_all_children(quest_reward_container)
	quest_reward_controls.clear()
	
	if is_instance_valid(quest_to_get_details_from):
		for item : Item in quest_to_get_details_from.quest_reward_array:
			var reward_control : QuestItemRewardControl = find_existing_reward_control_with_same_item_id(item)
			
			if reward_control:
				reward_control.add_quantity_from_item(item)
			else:
				add_quest_reward_control_for_item(item)


func add_quest_reward_control_for_item(item : Item):
	var new_quest_reward_control : QuestItemRewardControl = quest_reward_item_control.instantiate()
	quest_reward_container.add_child(new_quest_reward_control)
	quest_reward_controls.append(new_quest_reward_control)
	new_quest_reward_control.assign_item(item)


# ---------- Button Visibility Functions ---------- #

func update_accept_button():
	if accept_button:
		if can_accept_current_quest():
			accept_button.show()
		else:
			accept_button.hide()


func update_complete_button():
	if complete_button:
		if can_complete_current_quest():
			complete_button.show()
		else:
			complete_button.hide()


func update_track_button():
	if track_button:
		if can_track_current_quest():
			track_button.show()
		else:
			track_button.hide()
			


# ---------- Helper Functions ----------- #


func player_has_currently_selected_quest() -> bool:
	if is_instance_valid(quest_to_get_details_from):
		return QuestSystemMaster.has_quest_id(quest_to_get_details_from.quest_id)
	return false


func can_accept_current_quest():
	if allow_quest_acceptance:
		return is_instance_valid(quest_to_get_details_from) and not player_has_currently_selected_quest()


func can_complete_current_quest():
	if allow_quest_completion:
		return is_instance_valid(quest_to_get_details_from) and quest_to_get_details_from.can_complete()


func can_track_current_quest():
	return is_instance_valid(quest_to_get_details_from) and player_has_currently_selected_quest() and not QuestSystemMaster.find_quest_by_id(quest_to_get_details_from.quest_id).is_complete and not QuestSystemMaster.is_tracking_quest_id(currently_selected_quest.quest_id)


# --------- Linked Signals ---------- #


func _on_close_button_pressed() -> void:
	close_quest_menu()


func _on_quest_list_control_item_selected(index: int) -> void:
	if quest_to_control_mapping.has(index):
		on_select_quest(quest_to_control_mapping[index])


func _on_accept_button_pressed():
	if can_accept_current_quest():
		quest_to_get_details_from.start_copy_of_quest()
		
		# Changing the quest_to_get_details_from in case some steps are already complete
		var player_quest : Quest = QuestSystemMaster.find_quest_by_id(quest_to_get_details_from.quest_id)
		if player_quest:
			quest_to_get_details_from = player_quest
			quest_to_get_details_from.update_step_completion_status()
		
		update()


func _on_complete_button_pressed():
	if can_complete_current_quest():
		var player_quest : Quest = QuestSystemMaster.find_quest_by_id(quest_to_get_details_from.quest_id)
		if player_quest:
			player_quest.complete()
			var complete_title =  player_quest.display_name
			deselect_quest()
			update()
		# show_quest_complete(complete_title)


func _on_track_button_pressed():
	if can_track_current_quest():
		if player_has_currently_selected_quest() and not QuestSystemMaster.is_tracking_quest_id(quest_to_get_details_from.quest_id):
			QuestSystemMaster.set_active_quest_id_for_ui(quest_to_get_details_from.quest_id)
			update()
