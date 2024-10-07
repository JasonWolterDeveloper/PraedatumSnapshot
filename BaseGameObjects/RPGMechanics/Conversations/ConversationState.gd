class_name ConversationState extends Node

@export var unique_id : String = ""
@export var next_state : ConversationState

signal started
signal ended


func start_state():
	started.emit()
	
	
func end_state():
	ended.emit()


func advance_state():
	end_state()
