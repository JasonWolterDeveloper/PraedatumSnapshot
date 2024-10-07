extends Control

var warrior_used_ability_points_label : Label
var warrior_available_ability_points_label : Label

var warrior : Warrior


func _ready():
	warrior_used_ability_points_label = Util.find_node_by_name(self, "WarriorUsedAbilityPointsLabel")
	warrior_available_ability_points_label = Util.find_node_by_name(self, "WarriorAvailableAbilityPointsLabel")


func assign_warrior(new_warrior : Warrior):
	warrior = new_warrior
	update()


func update():
	if warrior:
		warrior_used_ability_points_label.text = str(warrior.used_ability_points)
		warrior_available_ability_points_label.text = str(warrior.get_total_ability_points())
