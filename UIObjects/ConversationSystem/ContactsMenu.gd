class_name ContactsMenu extends Control


var contacts_menu_panel : Control
var conversation_menu : ConversationMenu

var current_conversation : Conversation


func _ready():
	contacts_menu_panel = Util.find_node_by_name(self, "ContactsMenuPanel")
	conversation_menu = Util.find_node_by_name(self, "ConversationMenu")
	assign_contact_menu_recursively(self)


func assign_contact_menu_recursively(node):
	# Check if the node exists and has children
	if node != null and node.is_inside_tree():
		# Iterate through each child of the current node
		for child in node.get_children():
			# Check if the child node is of type "ContactButton"
			if child is ContactButton:
					child.assign_contacts_menu(self)
			
			# Recursively call this function on the child node
			assign_contact_menu_recursively(child)


func start_conversation(conversation_scene : PackedScene):
	current_conversation = conversation_scene.instantiate()
	add_child(current_conversation)
	contacts_menu_panel.hide()
	conversation_menu.show()
	ConversationMaster.finished_conversation.connect(end_conversation)
	current_conversation.start_state()


func end_conversation():
	contacts_menu_panel.show()
	conversation_menu.hide()
	remove_child(current_conversation)
	current_conversation.queue_free()
	current_conversation = null
