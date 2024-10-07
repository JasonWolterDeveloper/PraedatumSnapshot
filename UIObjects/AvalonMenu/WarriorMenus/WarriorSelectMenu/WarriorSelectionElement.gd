class_name WarriorSelectionElement extends PanelContainer

# ----- Necessary Model Variables ----- #
var warrior : Warrior

# ----- UI Element References ----- #
var warrior_name_label : Label
var select_button : Button

signal warrior_changed


func _ready():
	warrior_name_label = Util.find_node_by_name(self, "WarriorNameLabel")
	select_button = Util.find_node_by_name(self, "SelectButton")


func assign_warrior(new_warrior: Warrior):
	warrior = new_warrior
	update()


func update():
	warrior_name_label.text = warrior.display_name
	if WarriorMaster.get_selected_warrior() == warrior:
		select_button.text = "Selected"
		select_button.disabled = true
	else:
		select_button.text = "Select"
		select_button.disabled = false


func _on_button_pressed():
	WarriorMaster.swap_to_warrior(warrior.warrior_id)
	warrior_changed.emit()
	pass # Replace with function body.
