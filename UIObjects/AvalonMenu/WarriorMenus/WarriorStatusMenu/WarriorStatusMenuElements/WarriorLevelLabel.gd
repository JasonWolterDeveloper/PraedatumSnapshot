extends Control


var warrior_level_label : Label

var warrior : Warrior


func _ready():
	warrior_level_label = Util.find_node_by_name(self, "LevelLabel")


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	update()
	

func update():
	if warrior:
		warrior_level_label.text = str(warrior.current_level)
