class_name ConversationMenu extends Control

const DEFAULT_NUMBER_OF_CHARACTERS_FOR_ANIMATION : float = 50.0
const CONVERSATION_CHOICE_BUTTON_SCENE = preload("res://UIObjects/ConversationSystem/ConversationChoiceButton.tscn")

const CENTER_START_TAG = "[center]"
const CENTER_END_TAG = "[/center]"

@export var text_type_animation_speed_factor : float = 1.0
@onready var animation_player := $AnimationPlayer
@onready var quest_menu := $QuestMenu


var dialog_text : RichTextLabel
var conversation_choice_list : VBoxContainer

# A flag to indicate that we are currently animating text to prevent clicking
# from immediately progressing us
var is_animating_text = false


func _ready():
	dialog_text = Util.find_node_by_name(self, "DialogText")
	conversation_choice_list = Util.find_node_by_name(self, "ConversationChoiceList")
	ConversationMaster.assign_current_conversation_menu(self)


func _process(delta):
	if Input.is_action_just_pressed("ui_click") or Input.is_action_just_pressed("ui_accept"):
		if not is_animating_text:
			ConversationMaster.advance_current_conversation_state()
		else:
			skip_text_animation()
	if Input.is_action_just_pressed("debug_3"):
		quest_menu.update()
		quest_menu.show()


func display_conversation_dialog_state(state : ConversationDialogState):
	update_dialog_text(state.text)
	is_animating_text = true
	animate_type_dialog_text()


func clear_conversation_choice_list():
	var children_count = conversation_choice_list.get_child_count()
	
	# Iterate backwards to safely remove items
	for i in range(children_count - 1, -1, -1):
		var child = conversation_choice_list.get_child(i)
		
		# Check if the child is of type Button
		if child is ConversationChoiceButton:
			# Remove the child from the scene tree
			conversation_choice_list.remove_child(child)
			
			# Optionally delete the node to free memory
			child.queue_free()


func display_conversation_choice_state(state : ConversationChoiceState):
	clear_conversation_choice_list()
	populate_conversation_choice_list_from_conversation_choice_state(state)
	conversation_choice_list.show()


func hide_conversation_choice_state():
	clear_conversation_choice_list()
	conversation_choice_list.hide()
	

func populate_conversation_choice_list_from_conversation_choice_state(state : ConversationChoiceState):
	for my_choice : ConversationChoice in state.available_conversation_choices:
		var new_button = CONVERSATION_CHOICE_BUTTON_SCENE.instantiate()
		new_button.build_from_conversation_choice(my_choice)
		conversation_choice_list.add_child(new_button)
	
	
func animate_type_dialog_text():
	dialog_text.visible_characters = 0
	var animation_speed_factor = text_type_animation_speed_factor * DEFAULT_NUMBER_OF_CHARACTERS_FOR_ANIMATION / float(len(dialog_text.text))  
	animation_player.speed_scale = animation_speed_factor
	animation_player.play("type_text_animation")


func skip_text_animation():
	animation_player.stop()
	dialog_text.visible_ratio = 1
	on_animate_type_dialog_text_finished()


func on_animate_type_dialog_text_finished():
	is_animating_text = false
	

## build_dialog_text builds the actual string that goes into the dialog box including
## bbcode tags
func build_dialog_text(new_text : String):
	var bb_code_string = CENTER_START_TAG + new_text + CENTER_END_TAG
	return bb_code_string


func update_dialog_text(new_text : String):
	dialog_text.text = build_dialog_text(new_text)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "type_text_animation":
		on_animate_type_dialog_text_finished()


func open_quest_menu_for_quest_list(quest_list : Node):
	quest_menu.populate_quests_from_quest_list(quest_list)
	quest_menu.deselect_quest()
	quest_menu.update()
	quest_menu.show()
