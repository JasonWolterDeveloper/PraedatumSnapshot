extends Control

var mouse_inside = false

var player_can_use = false

@onready var interaction_button = $interactionButton

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if mouse_inside:
			if get_interactable_object():
				get_interactable_object().attempt_player_interaction()

func update_icons():
	if player_can_use:
		interaction_button.disabled = false
	else:
		interaction_button.disabled = true
	
func get_interactable_object():
	return get_parent()

func _on_interaction_button_mouse_entered():
	mouse_inside = true

func _on_interaction_button_mouse_exited():
	mouse_inside = false
