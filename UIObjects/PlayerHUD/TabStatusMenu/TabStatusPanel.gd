class_name TabStatusPanel extends Control

var quest_tracker : QuestTracker


func _ready():
	quest_tracker = Util.find_node_by_name(self, "QuestTracker")


func _process(delta):
	if Input.is_action_pressed("tab_menu_button"):
		show()
	else:
		hide()
