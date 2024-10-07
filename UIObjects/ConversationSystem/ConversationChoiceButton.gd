class_name ConversationChoiceButton extends Button

var conversation_choice : ConversationChoice


func build_from_conversation_choice(new_conversation_choice : ConversationChoice):
	conversation_choice = new_conversation_choice
	text = conversation_choice.text


func _on_pressed():
	conversation_choice.handle_select()
