class_name DisplayHintEffect extends TriggerEffect

@export_multiline var text: String = ""
@export var hint_character : ConversationCharacter = null
@export var portrait_id : String = "default"
@export var priority : int = 1
@export var display_time : float = 12.0


func activate_effect():
	OnScreenMessageMaster.display_hint(text, hint_character, portrait_id, display_time, priority)
