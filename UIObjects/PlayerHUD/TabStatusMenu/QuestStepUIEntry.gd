class_name QuestStepUIEntry extends MarginContainer

var quest_step : QuestStep
var quest : Quest

var selected_indicator : Control
var complete_indicator : Control
var incomplete_indicator : Control
var quest_step_name : Label


func _ready():
	selected_indicator = Util.find_node_by_name(self, "SelectedIndicator")
	complete_indicator = Util.find_node_by_name(self, "CompleteIndicator")
	incomplete_indicator = Util.find_node_by_name(self, "IncompleteIndicator")
	quest_step_name = Util.find_node_by_name(self, "QuestStepName")


func build_from_quest_step(new_quest_step : QuestStep):
	quest_step = new_quest_step
	quest = quest_step.get_quest()
	quest_step.completed.connect(update_from_quest_step)
	
	setup_complete_incomplete_indicator()
	setup_quest_step_name_label()
	setup_selected_indicator()


func setup_complete_incomplete_indicator():
	if quest_step.is_complete:
		complete_indicator.show()
		incomplete_indicator.hide()
	else:
		complete_indicator.hide()
		incomplete_indicator.show()


func setup_quest_step_name_label():
	quest_step_name.text = quest_step.display_name


func setup_selected_indicator():
	if quest.get_current_quest_step() == quest_step:
		selected_indicator.show()
	else:
		selected_indicator.hide()


func update_from_quest_step():
	setup_complete_incomplete_indicator()
	setup_quest_step_name_label()
	setup_selected_indicator()
