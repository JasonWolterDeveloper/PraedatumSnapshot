class_name ConversationDialogState extends ConversationState

@export var conversation_character : ConversationCharacter

@export_multiline var text : String


func start_state():
	ConversationMaster.current_conversation_state = self
	if ConversationMaster.conversation_menu != null:
		ConversationMaster.conversation_menu.display_conversation_dialog_state(self)
