class_name InteractionIcon extends Control

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var interaction_ghost_texture = $VBoxContainer/GhostTextureRect

@onready var prompt_text_container = $VBoxContainer/VBoxContainer
@onready var prompt_text = $VBoxContainer/VBoxContainer/Panel/MarginContainer/PromptText
@onready var sub_text = $VBoxContainer/VBoxContainer/Panel2/MarginContainer2/SubText

## Used to display an image of a different key/button to indicate what button needs
## to be pressed for this input
func update_interaction_icon_for_input_string(input_string : String):
	texture_rect.texture = InteractionIconMapper.get_icon_for_input(input_string)


func update_prompt_text(text : String):
	prompt_text.text = text


func update_sub_text(text : String):
	sub_text.text = text


func show_selected_for_interaction():
	show()
	texture_rect.show()
	prompt_text_container.show()
	interaction_ghost_texture.hide()
	

func show_interaction_ghost():
	show()
	texture_rect.hide()
	prompt_text_container.hide()
	interaction_ghost_texture.show()


func hide_all():
	hide()
