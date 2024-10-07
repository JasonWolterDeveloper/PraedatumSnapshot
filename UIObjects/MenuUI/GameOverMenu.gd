extends Control

signal return_to_hub


func _on_return_to_hub_button_pressed():
	return_to_hub.emit()
