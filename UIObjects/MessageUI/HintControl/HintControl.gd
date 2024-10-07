class_name HintControl extends Control

# ----- Parameter Variables ----- #
# @export var text_display : String = ""
# @export var hint_character : ConversationCharacter = null
# @export var portrait_id = "default"
var current_hint_priority : int = 1

var current_display_time : float = 0.0
var is_displaying : bool = false

# ----- Control Variables ----- #
var portrait_control : TextureRect
var name_label : RichTextLabel
var hint_label : RichTextLabel
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready():
	portrait_control = Util.find_node_by_name(self, "Portrait")
	name_label = Util.find_node_by_name(self, "NameLabel")
	hint_label = Util.find_node_by_name(self, "HintLabel")


func display_hint(text : String, conversation_character : ConversationCharacter, portrait_id : String = "default", display_time : float = 5.0, priority : int = 1):
	if not is_displaying or priority >= current_hint_priority:
		update_character(conversation_character, portrait_id)
		update_text(text)
		current_display_time = display_time
		show()
		
		if not is_displaying:
			fade_in_hint()
			
		is_displaying = true


# --------- Update and Process Functions --------- #
	
func update_character(hint_character : ConversationCharacter, portrait_id : String):
	var name_label_colour_code = "[color=#" + hint_character.display_name_colour.to_html(false) + "]"
	name_label.text = name_label_colour_code + hint_character.display_name
	portrait_control.texture = hint_character.get_portrait_for_key(portrait_id)


func update_text(text : String):
	hint_label.text = text


func _process(delta : float) -> void:
	if is_displaying:
		current_display_time -= delta
		if current_display_time <= 0:
			is_displaying = false
			fade_out_hint()


func fade_in_hint():
	animation_player.play("FadeIn")
	

func fade_out_hint():
	animation_player.play("FadeOut")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		hide()
