class_name Conversation extends ConversationState

var current_state : ConversationState
@export var initial_state : ConversationState

## converation_root is a boolean that indicates if this is the root of the convo
## tree
@export var conversation_root : bool 


func start_state():
	start_child_state(initial_state)
	super()
	
	
func end_state():
	if conversation_root:
		ConversationMaster.conversation_ended()
	super()


func on_current_state_ended():
	if current_state.ended.is_connected(on_current_state_ended):
		current_state.ended.disconnect(on_current_state_ended)
		
	# If our current state has a next state, we move to that state
	if current_state.next_state != null:
		start_child_state(current_state.next_state)
	# Otherwise, we end this conversation as well
	else:
		end_state()


func start_child_state(child_state : ConversationState):
	current_state = child_state
	current_state.ended.connect(on_current_state_ended)
	child_state.start_state()
