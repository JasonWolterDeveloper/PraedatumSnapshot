extends Node

var conversation_menu : ConversationMenu

var current_conversation_state : ConversationState

signal finished_conversation


func advance_current_conversation_state():
	if is_instance_valid(current_conversation_state) and current_conversation_state is ConversationDialogState:
		current_conversation_state.advance_state()


func assign_current_conversation_menu(new_conversation_menu):
	conversation_menu = new_conversation_menu
	

func modify_data_tome(key: String, value):
	PersistentDataTome.set_data_for_key(key, value)


func start_quest(quest_scene : PackedScene):
	var quest : Quest = quest_scene.instantiate()
	QuestSystemMaster.add_quest(quest)
	QuestSystemMaster.set_active_quest_id_for_ui(quest.quest_id)


func use_conversation_choice_function(function_name : String, parameters : Array):
	match function_name:
		"modify_data_tome":
			modify_data_tome(parameters[0], parameters[1])
		"start_quest":
			start_quest(parameters[0])


func conversation_ended():
	current_conversation_state = null
	finished_conversation.emit()


# ---------- Quest Functions ---------- #

func request_open_quest_menu(quest_list : Node):
	conversation_menu.open_quest_menu_for_quest_list(quest_list)
