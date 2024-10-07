class_name QuestTracker extends Control

var quest_step_vbox_container : VBoxContainer
var quest_step_ui_scene = preload("res://UIObjects/PlayerHUD/TabStatusMenu/QuestStepUIEntry.tscn")
var quest_name_label : Label
var no_objectives_label : Label
var quest_complete_label : Label

var quest : Quest


func _ready():
	quest_step_vbox_container = Util.find_node_by_name(self, "QuestStepVboxContainer")
	quest_name_label = Util.find_node_by_name(self, "QuestNameLabel")
	quest_complete_label = Util.find_node_by_name(self, "QuestCompleteLabel")
	no_objectives_label = Util.find_node_by_name(self, "NoObjectivesLabel")
	
	# We should only have one quest tracker so we can assign it here
	QuestSystemMaster.assign_quest_tracker_ui(self)
	setup_from_quest(null)


func setup_from_quest(new_quest : Quest):
	quest = new_quest
	update_from_current_quest()


func update_from_current_quest():
	if quest == null:
		update_null_quest()
	else:
		update_not_null_quest()


func update_not_null_quest():
	quest_name_label.show()
	no_objectives_label.hide()
	setup_quest_name()
	setup_quest_complete()
	populate_quest_steps()


func update_null_quest():
	quest_complete_label.hide()
	quest_name_label.hide()
	no_objectives_label.show()
	reset_quest_vbox()
	

func setup_quest_name():
	if quest and quest_name_label:
		quest_name_label.text = quest.display_name


func setup_quest_complete():
	if quest and quest.is_complete:
		quest_complete_label.show()
	else:
		quest_complete_label.hide()


func reset_quest_vbox():
	var children_to_remove = []
	for my_child in quest_step_vbox_container.get_children():
		if my_child is QuestStepUIEntry:
			children_to_remove.append(my_child)
	for my_child in children_to_remove:
		quest_step_vbox_container.remove_child(my_child)
		my_child.queue_free()


func populate_quest_steps():
	if quest and quest_step_vbox_container:
		reset_quest_vbox()
		for my_quest_step in quest.step_list:
			var new_quest_step_ui : QuestStepUIEntry = quest_step_ui_scene.instantiate()
			
			quest_step_vbox_container.add_child(new_quest_step_ui)
			new_quest_step_ui.build_from_quest_step(my_quest_step)
