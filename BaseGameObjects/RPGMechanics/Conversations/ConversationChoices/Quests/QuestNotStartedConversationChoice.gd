class_name QuestNotStartedConversationChoice extends ConversationChoice

@export var quest_id : String


func is_available():
	if QuestSystemMaster.is_quest_started(quest_id):
		return false
	return super()
