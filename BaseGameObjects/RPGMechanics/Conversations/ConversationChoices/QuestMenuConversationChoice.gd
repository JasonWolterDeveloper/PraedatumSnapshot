class_name QuestMenuConversationChoice extends ConversationChoice

@export var quest_list : Node


func handle_select():
	ConversationMaster.request_open_quest_menu(quest_list)
	 
