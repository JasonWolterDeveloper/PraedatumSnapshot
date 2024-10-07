extends Control

var warrior_current_experience_label : Label
var warrior_required_experience_label : Label

var warrior : Warrior


func _ready():
	warrior_current_experience_label = Util.find_node_by_name(self, "WarriorCurrentXPLabel")
	warrior_required_experience_label = Util.find_node_by_name(self, "WarriorRequiredXPLabel")


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	update()


func update():
	if warrior:
		warrior_current_experience_label.text = str(warrior.current_experience_points)
		warrior_required_experience_label.text = str(warrior.get_experience_to_next_level())
