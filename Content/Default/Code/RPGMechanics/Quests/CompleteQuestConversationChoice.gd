class_name CompleteQuestConversationChoice extends ConversationChoice

@export var quest_id : String


func run_conversation_function():
	var my_quest : Quest = QuestSystemMaster.get_quest_by_id(quest_id)
	
	if my_quest:
		my_quest.complete()
	super()
