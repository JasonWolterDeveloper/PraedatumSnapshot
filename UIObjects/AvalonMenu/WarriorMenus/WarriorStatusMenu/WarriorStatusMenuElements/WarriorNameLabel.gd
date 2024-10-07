extends Control


var warrior_name_label : Label

var warrior : Warrior


func _ready():
	warrior_name_label = Util.find_node_by_name(self, "NameLabel")


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	update()
	

func update():
	if warrior:
		warrior_name_label.text = warrior.display_name
