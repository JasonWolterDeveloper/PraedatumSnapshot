class_name ConversationChoiceState extends ConversationState

var available_conversation_choices : Array[ConversationChoice] = []


func _ready():
	assign_state_to_choices()


func assign_state_to_choices():
	for my_child in get_children():
		if my_child is ConversationChoice:
			my_child.assign_conversation_choice_state(self)


func start_state():
	populate_available_conversation_choices()
	ConversationMaster.current_conversation_state = self
	ConversationMaster.conversation_menu.display_conversation_choice_state(self)
	super()
	
	
func end_state():
	ConversationMaster.conversation_menu.hide_conversation_choice_state()
	super()


## Populate_available_conversation_choices clears the respective array and then
## fills it with our children if they are available choices. NOTE: We only want
## to use our direct children for this, as, we could have nested conversation
## choices we do NOT want to include
func populate_available_conversation_choices():
	available_conversation_choices.clear()
	for my_child in get_children():
		if my_child is ConversationChoice:
			if my_child.is_available():
				available_conversation_choices.append(my_child)


func handle_select(conversation_choice : ConversationChoice):
	next_state = conversation_choice.next_state
	end_state()


func advance_state():
	# TODO Make it so the conversation master has an advance dialog state that
	# only advances if you have a dialog state selected
	
	# We only want to advance the state if we make a choice, so
	# we program this function to do nothing
	pass
