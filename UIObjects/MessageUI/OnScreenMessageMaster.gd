extends Node

const DEFAULT_MESSAGE_DURATION = 2.5


@onready var message_label : Label = $CanvasLayer/Label
@onready var display_timer : Timer = $DisplayTimer
var hint_control : HintControl
var hold_use_control : HoldUseHUDControl

var showing_message : bool = false
var current_message_priority : float = 1.0


func _ready():
	hint_control = Util.find_node_by_name(self, "HintControl")
	hold_use_control = Util.find_node_by_name(self, "HoldUseHUDControl")


func set_message_text(message_text : String):
	message_label.text = message_text


func set_current_message_priority(priority : float):
	current_message_priority = priority


func set_duration(duration : float):
	display_timer.wait_time = duration


func display_message(message_text : String, duration : float = DEFAULT_MESSAGE_DURATION, priority : float = 1.0):
	if priority >= current_message_priority:
		set_message_text(message_text)
		set_current_message_priority(priority)
		set_duration(duration)
		
		message_label.show()
		display_timer.start()


func display_hint(text : String, conversation_character : ConversationCharacter, portrait_id : String = "default", display_time : float = 5.0, priority : int = 1):
	if is_instance_valid(hint_control):
		hint_control.display_hint(text, conversation_character, portrait_id, display_time, priority)


## Takes progress, which should be a float between 0.0 and 100 representing the
## percentage completed the interaction is, and a display_text which is a string to
## display while interacting. Priority indicates whether or not we should override
## previous requests
func display_progress(progress : float, display_text  : String, priority : int = 1):
	hold_use_control.request_display_progress(progress, display_text, priority)


func _on_display_time_timeout():
	message_label.hide()
	set_current_message_priority(0.0)
