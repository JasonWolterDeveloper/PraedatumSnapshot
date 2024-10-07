class_name ContactButton extends Button

var contacts_menu : ContactsMenu

@export var contact_conversation_scene : PackedScene


func assign_contacts_menu(new_contacts_menu : ContactsMenu):
	contacts_menu = new_contacts_menu


func start_conversation():
	contacts_menu.start_conversation(contact_conversation_scene)


func _on_pressed():
	start_conversation()
