class_name StartQuestConversationChoice extends ConversationChoice

@export var quest_scene : PackedScene


func run_conversation_function():
	ConversationMaster.start_quest(quest_scene)
	super()
