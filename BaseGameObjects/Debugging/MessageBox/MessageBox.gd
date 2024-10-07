extends Control


class_name MessageBox

@onready var grid = $Grid
@onready var background = $Background
var messages = []
const MAX_MESSAGS = 10
const MESSAGE_SCENE = preload("res://BaseGameObjects/Debugging/MessageBox/MessageBoxMessage.tscn")

func _ready():
	hide()

func get_messages():
	return messages
	
func get_oldest_message():
	return get_messages()[0]

func add_message(text):
	var new_message = MESSAGE_SCENE.instantiate()
	new_message.text = text
	get_messages().append(new_message)
	Util.force_add_child(grid, new_message)
	
	if messages.size() > MAX_MESSAGS:
		delete_message(get_oldest_message())
		
	show()
		

func delete_message(message):
	get_messages().remove_at(get_messages().find(message))
	grid.remove_child(message)
	
	if get_messages().is_empty():
		hide()

func _process(delta):
	for message in get_messages():
		if message.check_should_delete():
			delete_message(message)
